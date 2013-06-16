# RDF::DataObjects

DataObjects-backed RDF.rb repository, aiming for a simple use case and
currently targeting SQLite and Postgres.

 * <http://github.com/ruby-rdf/rdf-do>
 * <http://lists.w3.org/Archives/Public/public-rdf-ruby>

[![Gem Version](https://badge.fury.io/rb/rdf-do.png)](http://badge.fury.io/rb/rdf-do)
[![Build Status](https://travis-ci.org/ruby-rdf/rdf-do.png?branch=1.1)](http://travis-ci.org/ruby-rdf/rdf-do)

This was written for a tutorial, and is thus a pretty naive implementation so far.
RDF::DataObjects stores triples in a simple subject, predicate, object, context
table.  Don't try to back a big website with it yet.  Nonetheless, it works,
and it passes all its tests on Heroku as well.

Example:

    repository = RDF::DataObjects::Repository.new "sqlite3:test.db"
    repository.insert(statement)
    repository.count              #=> 1
    repository.delete(statement)

You can use any DataObjects compatible connection options to create a new
repository, but only SQLite3 and Postgres are implemented for now.  The
different databases are *just* different enough with their handling of unique
constraints that some database-specific work is required for a new adapter, but
it's not much.

## Installation:

The greatly preferred installation method is via RubyGems:

    $ sudo gem install rdf-do

Requires Ruby >= 1.9.2

## Connecting:
    require 'rdf'
    require 'rdf/do'
    require 'do_postgres' # gem install do_postgres
    require 'do_sqlite3'  # gem install do_sqlite3
    repo = RDF::DataObjects::Repository.new "postgres://localhost/database"
    repo = RDF::DataObjects::Repository.new "sqlite3:test.db"


## Using:

Your repository is a fully-functional RDF.rb `RDF::Repository`.  As with any
RDF.rb repository, this includes the mixins `RDF::Enumerable`, `RDF::Mutable`,
`RDF::Durable`, and `RDF::Queryable`.  Please see <http://rdf.rubyforge.org/RDF/Repository.html> for
more information.

Example:

    require 'rdf'
    require 'rdf/ntriples'
    require 'data_objects'
    require 'do_sqlite3'
    require 'rdf/do'

    repo = RDF::DataObjects::Repository.new('sqlite3:test.db')
    # repo = RDF::DataObjects::Repository.new 'postgres://postgres@server/database'
    # heroku_repo = RDF::DataObjects::Repository.new(ENV['DATABASE_URL'])
    repo.load('http://datagraph.org/jhacker/foaf.nt')

    # How many statements did we have?
    repo.count
    #=> 10

    # Get the URI of the first subject
    jhacker = repo.first.subject
    #=> #<RDF::URI(http://datagraph.org/jhacker/foaf)>

    # Delete everything to do with it
    jhacker_statements = repo.query(:subject => jhacker) 
    repo.delete *jhacker_statements
    repo.count
    #=> 7

    # with Postgres, we could have done this, but SQLite gives us a locking error:
    # repo.delete(*repo.query(:subject => jhacker))

    # Changed our mind--bring it back
    repo.insert *jhacker_statements
    repo.count
    #=> 10



### Developing

The main project page is on Github, at <http://github.com/ruby-rdf/rdf-do>.  You
can get a working copy of the source tree with:

    $ git clone git://github.com/ruby-rdf/rdf-do.git

Or with:

    $ wget http://github.com/ruby-rdf/rdf-do/tarball/master

### Support

The preferred method to report issues is the issue queue at
<http://github.com/ruby-rdf/rdf-do/issues>.  You'll get the the most attention if
you submit a failing test for a bug, or a pending test for a feature. 

We'd also like to hear from you on the mailing list:
<http://lists.w3.org/Archives/Public/public-rdf-ruby>

### Miscellany

 * Author: Ben Lavender | <blavender@gmail.com> | <http://bhuga.net> | <http://blog.datagraph.org>
 * 'License':  RDF::DataObjects is free and unemcumbered software released into the public domain.  For more information, see the included UNLICENSE file.

