require 'data_objects'
require 'rdf/ntriples'
require 'enumerator'

module RDF
  module DataObjects
    class Repository

      include RDF::Enumerable, RDF::Queryable, RDF::Mutable, RDF::Durable

      def initialize(options = {})
        case options
          when String
            @db     = ::DataObjects::Connection.new(options)
          when Hash
            @db     = ::DataObjects::Connection.new(options[:db])
            adapter = options[:adapter]
          when nil
            @db    = ::DataObjects::Connection.new('sqlite3://:memory:')
        end
        adapter = @db.instance_variable_get("@uri").scheme
        begin
          require 'rdf/do/adapters/' + adapter.to_s
        rescue LoadError => e
          warn "Unable to find adapter '#{adapter}'."
          raise e
        end
        @adapter = RDF::DataObjects::Adapters::const_get(adapter.to_s.capitalize)
        @adapter.migrate? self
      end

      def dispose
        close
        @db.dispose
      end

      def close
        @db.close
        @adapter = nil
      end

      def empty?
        count == 0
      end

      def insert_statement(statement)
        insert *[statement]
      end

      def delete_statement(statement)
        delete *[statement]
      end

      #def each(&block)
      #  if block_given?
      #    @adapter.each &block
      #  else
      #    enum_statements(@adapter, :each, @adapter)
      #  end
      #end

      def each(&block)
        if block_given?
          reader = result(@adapter.each_sql)
          while reader.next!
            block.call(RDF::Statement.new(
                      :subject   => unserialize(reader.values[0]),
                      :predicate => unserialize(reader.values[1]),
                      :object    => unserialize(reader.values[2]),
                      :context   => unserialize(reader.values[3])))
          end
        else
          ::Enumerable::Enumerator.new(self,:each)
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

      def each_or_enumerator(method, &block)
        if block_given?
          self.send(method, &block)
        else
          ::Enumerable::Enumerator.new(self,:each_or_enumerator)
        end
      end

      def each_subject(&block)
        each_or_enumerator(:subject_block, &block)
      end

      def subject_block(&block)
        reader = result(@adapter.each_subject_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      def each_predicate(&block)
        each_or_enumerator(:predicate_block, &block)
      end

      def predicate_block(&block)
        reader = result(@adapter.each_predicate_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      def each_object(&block)
        each_or_enumerator(:object_block, &block)
      end

      def object_block(&block)
        reader = result(@adapter.each_object_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      def each_context(&block)
        each_or_enumerator(:context_block, &block)
      end

      def context_block(&block)
        reader = result(@adapter.each_context_sql)
        while reader.next!
          context = unserialize(reader.values[0])
          block.call(context) unless context.nil?
        end
      end

      def insert(*statements)
        query = @adapter.insert_sql
        statements.each do |s|
          exec(query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
      end

      def delete(*statements)
        query = @adapter.delete_sql
        statements.each do |s|
          exec(query,serialize(s. subject),serialize(s.predicate), serialize(s.object), serialize(s.context)) 
        end
      end

      def query(pattern, &block)
        case pattern
          when RDF::Statement
            query(pattern.to_hash)
          when Array
            query(RDF::Statement.new(*pattern))
          when Hash
            statements = []
            reader = @adapter.query(self,pattern)
            while reader.next!
              statements << RDF::Statement.new(
                      :subject   => unserialize(reader.values[0]),
                      :predicate => unserialize(reader.values[1]),
                      :object    => unserialize(reader.values[2]),
                      :context   => unserialize(reader.values[3]))
            end
            case block_given?
              when true
                statements.each(&block)
              else
                statements.extend(RDF::Enumerable, RDF::Queryable)
            end
          else
            super(pattern) 
        end

      end

      def count
        result = result(@adapter.count_sql)
        result.next!
        result.values.first
      end

    end
  end
end

