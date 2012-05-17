require 'rdf/do/adapters/defaults'

module RDF::DataObjects
  module Adapters

    ##
    # Postgres Adapter for RDF::DataObjects.
    #
    class Postgres
      
      self.extend Defaults

      ##
      # Indempotently migrate this database.
      #
      # @param [RDF::DataObjects::Repository] do_repository
      # @return [void]
      def self.migrate?(do_repository, opts = {})
        begin do_repository.exec('CREATE TABLE quads (subject varchar(255), predicate varchar(255), object varchar(255), context varchar(255), UNIQUE (subject, predicate, object, context))') rescue nil end
        begin do_repository.exec('CREATE INDEX quads_context_index ON quads (context)') rescue nil end
        begin do_repository.exec('CREATE INDEX quads_object_index ON quads (object)') rescue nil end
        begin do_repository.exec('CREATE INDEX quads_predicate_index ON quads (predicate)') rescue nil end
        begin do_repository.exec('CREATE INDEX quads_subject_index ON quads (subject)') rescue nil end
        do_repository.exec('CREATE OR REPLACE RULE "insert_ignore" AS ON INSERT TO quads WHERE EXISTS(SELECT true FROM quads WHERE subject = NEW.subject AND predicate = NEW.predicate AND object = NEW.object AND context = NEW.context) DO INSTEAD NOTHING;')
      end

      # SQL prepared statement for insertions
      #
      # @return [String]
      def self.insert_sql
        'insert into quads (subject, predicate, object, context) VALUES (?, ?, ?, ?)'
      end

      # SQL prepared statement for multiple insertion
      #
      # @param  [Integer] count The number of statements to be inserted
      # @return [String]
      def self.multiple_insert_sql(count)
        sql = 'insert into quads (subject, predicate, object, context) VALUES '
        sql + (1..count).map { "(?, ?, ?, ?)" }.join(',')
      end

      # SQL prepared statement for deletions
      #
      # @return [String]
      def self.delete_sql 
        "DELETE FROM quads where (subject = ? AND predicate = ? AND object = ? AND context = ?)"
      end

    end
  end
end

