require 'rdf/ntriples'
require 'enumerator'

## TODO: Indexes, escaping, efficient querying, efficient each_subject/predicate/object/etc.

module RDF::DataObjects
  module Adapters
    class Sqlite3

      def self.migrate?(do_repository, opts = {})
        do_repository.exec('CREATE TABLE quads (`subject` varchar(255), `predicate` varchar(255), `object` varchar(255), `context` varchar(255), UNIQUE (`subject`, `predicate`, `object`, `context`))')
        begin do_repository.exec('CREATE INDEX `quads_context_index` ON `quads` (`context`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_object_index` ON `quads` (`object`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_predicate_index` ON `quads` (`predicate`)') rescue nil end
        begin do_repository.exec('CREATE INDEX `quads_subject_index` ON `quads` (`subject`)') rescue nil end
      end

      def self.count_sql
        'select count(*) from `quads`'
      end

      def self.insert_sql
        'REPLACE INTO `quads` (subject, predicate, object, context) VALUES (?, ?, ?, ?)'
      end

      def self.delete_sql
        'DELETE FROM `quads` where (subject = ? AND predicate = ? AND object = ? AND context = ?)'
      end

      def self.query
        # only deal with hash here
      end

      def self.each_sql
        'select * from quads'
      end

    end
  end
end

