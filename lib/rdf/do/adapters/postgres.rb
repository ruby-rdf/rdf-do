require 'rdf/ntriples'
require 'enumerator'

## TODO: Indexes, escaping, efficient querying, efficient each_subject/predicate/object/etc.

module RDF::DataObjects
  module Adapters
    class Postgres

      attr_accessor :db

      def initialize(db)
        @db = db
      end


      def migrate?(opts = {})
        begin exec('CREATE TABLE quads (subject varchar(255), predicate varchar(255), object varchar(255), context varchar(255), UNIQUE (subject, predicate, object, context))') rescue nil end
        begin exec('CREATE INDEX quads_context_index ON quads (context)') rescue nil end
        begin exec('CREATE INDEX quads_object_index ON quads (object)') rescue nil end
        begin exec('CREATE INDEX quads_predicate_index ON quads (predicate)') rescue nil end
        begin exec('CREATE INDEX quads_subject_index ON quads (subject)') rescue nil end
        exec('CREATE OR REPLACE RULE "insert_ignore" AS ON INSERT TO quads WHERE EXISTS(SELECT true FROM quads WHERE subject = NEW.subject AND predicate = NEW.predicate AND object = NEW.object AND context = NEW.context) DO INSTEAD NOTHING;')
        
      end

      def count
        result = result('select count(*) from quads')
        result.next!
        result.values.first
      end

      def insert(*statements)
        query = "insert into quads (subject, predicate, object, context) VALUES (?, ?, ?, ?)"
        statements.each do |s|
          exec(query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
        
      end

      def delete(*statements)
        query = "DELETE FROM quads where (subject = ? AND predicate = ? AND object = ? AND context = ?)"
        statements.each do |s|
          exec(query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
      end

      def query(query_stuff)
        # only deal with hash here
      end

      def each_subject(&block)
        if block_given?
        else
          self.enum_subjects
        end
      end

      def each(&block)
        reader = result('select * from quads')
        while reader.next!
          block.call(RDF::Statement.new(
                      :subject   => unserialize(reader.values[0]),
                      :predicate => unserialize(reader.values[1]),
                      :object    => unserialize(reader.values[2]),
                      :context   => unserialize(reader.values[3])))
        end
      end

      def serialize(value)
        value.nil? ? 'nil' : RDF::NTriples::Writer.serialize(value)
      end

      def unserialize(value)
        value == 'nil' ? nil : RDF::NTriples::Reader.unserialize(value)
      end
      
      def exec(sql, *args)
        @db.create_command(sql).execute_non_query(*args)
      end

      def result(sql, *args)
        @db.create_command(sql).execute_reader(*args)
      end

    end
  end
end

