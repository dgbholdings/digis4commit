module PeercoinBalanceUpdater
  def self.work
    Project.enabled.each do |project|
      start = 0
      count = 10

      raise "Project without address label: #{project.inspect}" if project.address_label.blank?

      if project.cold_storage_withdrawal_address.blank?
        new_address = PeercoinDaemon.instance.get_new_address(project.address_label)
        project.update!(cold_storage_withdrawal_address: new_address)
      end

      loop do
        transactions = PeercoinDaemon.instance.list_transactions(project.address_label, count, start)
        break if transactions.empty?

        transactions.each do |transaction|
          txid = transaction["txid"]
          confirmations = transaction["confirmations"]
          category = transaction["category"]

          next if Sendmany.where(txid: txid).any?

          if deposit = Deposit.find_by_txid(txid)
            deposit.update_attribute(:confirmations, confirmations)
            next
          end

          if cold_storage_transfer = ColdStorageTransfer.find_by_txid(txid)
            cold_storage_transfer.update_attribute(:confirmations, confirmations)
            next
          end

          address = transaction["address"]
          if address.blank?
            raise "Invalid transaction: #{transaction.inspect}"
          end

          cold_storage_addresses = CONFIG["cold_storage"].try(:[], "addresses") || []
          cold_storage_withdrawal_address = project.cold_storage_withdrawal_address

          amount = (transaction["amount"].to_d * COIN).to_i

          if address == cold_storage_withdrawal_address
            if category != "receive"
              raise "Unexpected cold storage withdrawal: #{transaction.inspect}"
            end

            project.cold_storage_transfers.create!(
              address: address,
              txid: txid,
              confirmations: confirmations,
              amount: -amount,
            )
            next
          end

          if cold_storage_addresses.include?(address)
            if category != "send"
              raise "Unexpected cold storage transaction: #{transaction.inspect}"
            end

            project.cold_storage_transfers.create!(
              address: address,
              txid: txid,
              confirmations: confirmations,
              amount: -amount,
            )
            next
          end

          if category == "receive"
            if address != project.bitcoin_address
              raise "Funds received to unexpected address: #{transaction.inspect}"
            end

            deposit = Deposit.create(
              project_id: project.id,
              txid: txid,
              confirmations: confirmations,
              amount: amount,
              duration: 30.days.to_i,
              paid_out: 0,
              paid_out_at: Time.now,
            )
            next
          end

          raise "Unexpected transaction: #{transaction.inspect}"
        end

        break if transactions.size < count
        start += count
      end
    end
  end
end
