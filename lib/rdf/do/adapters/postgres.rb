require 'rdf/ntriples'
require 'enumerator'

## TODO: Indexes, escaping, efficient querying, efficient each_subject/predicate/object/etc.

module RDF::DataObjects
  module Adapters
    module Postgres

      def self.migrate?(db, opts = {})
        begin db_exec(db, 'CREATE TABLE quads (subject varchar(255), predicate varchar(255), object varchar(255), context varchar(255), UNIQUE (subject, predicate, object, context))') rescue nil end
        begin db_exec(db, 'CREATE INDEX `quads_context_index` ON `quads` (`context`)') rescue nil end
        begin db_exec(db, 'CREATE INDEX `quads_object_index` ON `quads` (`object`)') rescue nil end
        begin db_exec(db, 'CREATE INDEX `quads_predicate_index` ON `quads` (`predicate`)') rescue nil end
        begin db_exec(db, 'CREATE INDEX `quads_subject_index` ON `quads` (`subject`)') rescue nil end
        begin db_exec(db, 'CREATE LANGUAGE plpgsql') rescue nil end
        db_exec(db, '
        CREATE OR REPLACE function insert_quad(s varchar(255), p varchar(255), o varchar(255), c varchar(255)) returns void as $$
          BEGIN
            INSERT INTO quads (subject, predicate, object, context) values (s, p, o, c); 
            EXCEPTION 
              WHEN unique_violation THEN
          END;
        $$
        language plpgsql;')

        
      end

      def self.count(db)
        result = db_result(db, 'select count(*) from quads')
        result.next!
        result.values.first
      end

      def self.insert(db, *statements)
        query = "select insert_quad(?, ?, ?, ?)"
        #query = "insert into quads (subject, predicate, object, context) VALUES (?, ?, ?, ?) ; exception when unique_violation then end;"
        statements.each do |s|
          db_exec(db,query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
        
      end

      def self.delete(db, *statements)
        query = "DELETE FROM quads where (subject = ? AND predicate = ? AND object = ? AND context = ?)"
        statements.each do |s|
          db_exec(db,query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
      end

      def self.query(db,query_stuff)
        # only deal with hash here
      end

      def self.each_subject(db, &block)
        if block_given?
        else
          self.enum_subjects
        end
      end

      def self.each(db, &block)
        reader = db_result(db, 'select * from quads')
        while reader.next!
          block.call(RDF::Statement.new(
                      :subject   => unserialize(reader.values[0]),
                      :predicate => unserialize(reader.values[1]),
                      :object    => unserialize(reader.values[2]),
                      :context   => unserialize(reader.values[3])))
        end
      end

      def self.serialize(value)
        value.nil? ? 'nil' : RDF::NTriples::Writer.serialize(value)
      end

      def self.unserialize(value)
        value == 'nil' ? nil : RDF::NTriples::Reader.unserialize(value)
      end
      
      def self.db_exec(db, sql, *args)
        db.create_command(sql).execute_non_query(*args)
      end

      def self.db_result(db, sql, *args)
        db.create_command(sql).execute_reader(*args)
      end

    end
  end
end

