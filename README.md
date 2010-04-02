# RDF::DataObjects

DataObjects-backed RDF.rb repository, aiming for a simple use case and
currently targeting SQLite and Postgres.  It passes its specs with Heroku's
database.

This was written for a tutorial, and is thus a pretty naive implementation:
RDF::DataObjects stores triples in a simple subject, predicate, object, context
table.  Don't try to back a big website with it yet.  Nonetheless, it works.

Example:
    repository = RDF::DataObjects::Repository.new "sqlite3:test.db"
    repository.insert(statement)
    repository.count              #=> 1
    repository.delete(statement)

You can use any DataObjects compatible connection options, but only SQLite3 and
Postgres are implemented for now.  The different databases are *just* different
enough with their handling of unique constraints that some database-specific
work is required, but it's not much.

## Installation:

The greatly preferred installation method is via RubyGems:

    $ sudo gem install rdf-do

Manual downloads are available at <http://github.com/bhuga/rdf-do/downloads>

## Connecting:
  
    repo = RDF::DataObjects::Repository.new "postgres://localhost/database"
    repo = RDF::DataObjects::Repository.new "sqlite3:test.db"


## Using:

Your repository is a fully-functional RDF.rb `RDF::Repository`.  As with any
RDF.rb repository, this includes the mixins `RDF::Enumerable`, `RDF::Mutable`,
`RDF::Durable`, and `RDF::Queryable`.  Please see <http://rdf.rubyforge.org> for
more information.

### Miscellany

 * Author: Ben Lavender <blavender@gmail.com> <http://bhuga.net> <http://blog.datagraph.org>
 * 'License':  RDF::DataObjects is free and unemcumbered software released into the public domain.  For more information, see the included UNLICENSE file.


