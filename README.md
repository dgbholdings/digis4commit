Digis4Commits
==========

[![DigiByte tip for next commit](http://Digis4Commits.com/projects/16.svg)](http://Digis4Commits.com/projects/16)


Donate digibytes to open source projects or make commits and get tips for it.

Official site: http://Digis4Commits.com/

Development
===========

To run Digis4Commits in development mode follow these instructions:

* Install [Ruby](https://www.ruby-lang.org/en/downloads/) 1.9+

* Install the [bundler](http://bundler.io/) gem (you may need root):
```
gem install bundler
```

* Install [git](http://git-scm.com/downloads)

* Clone the repository
```
git clone git@github.com:sigmike/Digis4Commits.git
cd Digis4Commits
```

* Install the sqlite3 development libraries

* Install the gems (without the production gems):
```
bundle install --without mysql postgresql
```

* Create `database.yml`.
```
cp config/database.yml{.sample,}
```

* Create `config.yml`
```
cp config/config.yml{.example,}
```

* Edit `config.yml`

* Initialize the database
```
    bundle exec rake db:migrate
```

* Make sure `ppcoind` is running with RPC enabled

* Run the server


    bundle exec rails server

* Connect to the server at http://localhost:3000/


To update the project balances run this command:
```
    bundle exec rails runner "BalanceUpdater.work"
```

To retreive commits and send tips on project that do not hold tips:
```
    bundle exec rails runner "BitcoinTipper.work"
```

License
=======

[MIT License](https://github.com/sigmike/Digis4Commits/blob/master/LICENSE)

Based on [Digis4Commits](http://Digis4Commits.com/), [MIT License](https://github.com/sigmike/Digis4Commits/blob/master/LICENSE), copyright (c) 2014 sigmike

Which is based on [Tip4commit](http://tip4commit.com/), [MIT License](https://github.com/tip4commit/tip4commit/blob/master/LICENSE), copyright (c) 2013-2014 tip4commit
