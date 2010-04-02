require 'rdf/ntriples'
require 'enumerator'

## TODO: Indexes, escaping, efficient querying, efficient each_subject/predicate/object/etc.

module RDF::DataObjects
  module Adapters
    module Sqlite3

      def self.migrate?(db, opts = {})
        prefix = opts[:prefix]
        db_exec(db, 'CREATE TABLE ? (`subject` varchar(255), `predicate` varchar(255), `object` varchar(255), `context` varchar(255), UNIQUE (`subject`, `predicate`, `object`, `context`))', "#{prefix}quads")
        begin db_exec('CREATE INDEX `quads_context_index` ON `quads` (`context`)') rescue nil end
        begin db_exec('CREATE INDEX `quads_object_index` ON `quads` (`object`)') rescue nil end
        begin db_exec('CREATE INDEX `quads_predicate_index` ON `quads` (`predicate`)') rescue nil end
        begin db_exec('CREATE INDEX `quads_subject_index` ON `quads` (`subject`)') rescue nil end
      end

      def self.count(db)
        result = db_result(db, 'select count(*) from `quads`')
        result.next!
        result.values.first
      end

      def self.insert(db, *statements)
        query = "REPLACE INTO `quads` (subject, predicate, object, context) VALUES (?, ?, ?, ?)"
        statements.each do |s|
          db_exec(db,query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
        
      end

      def self.delete(db, *statements)
        query = "DELETE FROM `quads` where (subject = ? AND predicate = ? AND object = ? AND context = ?)"
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

