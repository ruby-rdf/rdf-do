# RDF::DataObjects

DataObjects-backed [RDF.rb][] repository, aiming for a simple use case and
currently targeting SQLite and Postgres.

 * <https://github.com/ruby-rdf/rdf-do>
 * <https://lists.w3.org/Archives/Public/public-rdf-ruby>

[![Gem Version](https://badge.fury.io/rb/rdf-do.png)](https://badge.fury.io/rb/rdf-do)
[![Build Status](https://travis-ci.org/ruby-rdf/rdf-do.png?branch=master)](https://travis-ci.org/ruby-rdf/rdf-do)

This was written for a tutorial, and is thus a pretty naive implementation so far.
RDF::DataObjects stores triples in a simple subject, predicate, object, context
table.  Don't try to back a big website with it yet.  Nonetheless, it works,
and it passes all its tests on Heroku as well.

Example:

    repository = RDF::DataObjects::Repository.new uri: "sqlite3:test.db"
    repository.insert(statement)
    repository.count              #=> 1
    repository.delete(statement)

You can use any DataObjects compatible connection options to create a new
repository, but only SQLite3 and Postgres are implemented for now.  The
different databases are *just* different enough with their handling of unique
constraints that some database-specific work is required for a new adapter, but
it's not much.

## Installation

The greatly preferred installation method is via RubyGems:

    $ sudo gem install rdf-do

Requires Ruby >= 2.4

## Connecting
    require 'rdf'
    require 'rdf/do'
    require 'do_postgres' # gem install do_postgres
    require 'do_sqlite3'  # gem install do_sqlite3
    repo = RDF::DataObjects::Repository.new uri: "postgres://localhost/database"
    repo = RDF::DataObjects::Repository.new uri: "sqlite3:test.db"


## Using

Your repository is a fully-functional [RDF.rb][] `RDF::Repository`.
As with any [RDF.rb][] repository, this includes the mixins `RDF::Enumerable`, `RDF::Mutable`,
`RDF::Durable`, and `RDF::Queryable`.
Please see <https://www.rubydoc.info/github/ruby-rdf/rdf/RDF/Repository> for more information.

Example:

    require 'rdf'
    require 'rdf/ntriples'
    require 'data_objects'
    require 'do_sqlite3'
    require 'rdf/do'

    repo = RDF::DataObjects::Repository.new uri: 'sqlite3:test.db'
    # repo = RDF::DataObjects::Repository.new uri: 'postgres://postgres@server/database'
    # heroku_repo = RDF::DataObjects::Repository.new uri: ENV['DATABASE_URL']
    repo.load('http://datagraph.org/jhacker/foaf.nt')

    # How many statements did we have?
    repo.count
    #=> 10

    # Get the URI of the first subject
    jhacker = repo.first.subject
    #=> #<RDF::URI(http://datagraph.org/jhacker/foaf)>

    # Delete everything to do with it
    jhacker_statements = repo.query(subject: jhacker) 
    repo.delete *jhacker_statements
    repo.count
    #=> 7

    # with Postgres, we could have done this, but SQLite gives us a locking error:
    # repo.delete(*repo.query(subject: jhacker))

    # Changed our mind--bring it back
    repo.insert *jhacker_statements
    repo.count
    #=> 10

## Contributing
This repository uses [Git Flow](https://github.com/nvie/gitflow) to mange development and release activity. All submissions _must_ be on a feature branch based on the _develop_ branch to ease staging and integration.

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## Support

The preferred method to report issues is the issue queue at
<https://github.com/ruby-rdf/rdf-do/issues>.  You'll get the most attention if
you submit a failing test for a bug, or a pending test for a feature. 

We'd also like to hear from you on the mailing list:
<https://lists.w3.org/Archives/Public/public-rdf-ruby>

## Miscellany

* Author: Ben Lavender | <blavender@gmail.com> | <https://bhuga.net>
* 'License':  RDF::DataObjects is free and unencumbered software released into the public domain.  For more information, see the included UNLICENSE file.

[RDF.rb]:           https://rubygems.org/gems/rdf
[YARD]:             https://yardoc.org/
[YARD-GS]:          https://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              https://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
