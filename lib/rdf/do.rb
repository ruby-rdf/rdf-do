require 'data_objects'
require 'rdf/ntriples'
require 'enumerator'

module RDF

  ##
  # RDF::DataObjects offers an RDF::Repository which is backed by a DataObjects
  # connection.  All inserts and deletes to this repository are done in real
  # time; no flushing is required.
  #
  # Each RDF::DataObjects::Repository includes an RDF::DataObjects::Adapter, such as
  # RDF::DataObjects::Adapters::Sqlite3.
  #
  # @see RDF::DataObjects::Adapters
  # @see RDF::Repository
  module DataObjects

    ##
    # RDF::DataObjects::Repository is an RDF::Repository is backed by a
    # DataObjects connection.
    #
    class Repository < RDF::Repository

      ## Create a new RDF::DataObjects::Repository
      # 
      # The `options` parameter can be anything that
      # DataObjects::Connection.new accepts.  The correct
      # RDF::Repository::DataObjects adapter will be loaded based on the URI
      # scheme of the created connection.
      #
      # @example
      #     RDF::DataObjects::Repository.new  # => new Repository based on sqlite3://:memory:
      #     RDF::DataObjects::Repository.new 'postgres://localhost/database'  # => New repository based on postgres adapter
      # @param [Any] options
      # @return [RDF::DataObjects::Repository]
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
          #TODO: make this error clearer
          raise e
        end
        @adapter = RDF::DataObjects::Adapters::const_get(adapter.to_s.capitalize)
        @adapter.migrate? self
      end

      ##
      # Close and dispose of this connection.
      #
      # @return [void]
      def dispose
        close
        @db.dispose
      end

      ##
      # Close this connection.
      #
      # @return [void]
      def close
        @db.close
        @adapter = nil
      end

      ##
      # Returns true if this repository is empty.
      #
      # @see RDF::Enumerable#empty
      # @return [Boolean]
      def empty?
        count == 0
      end

      ##
      # Insert a single statement into this repository.
      #
      # @see RDF::Mutable#insert_statement
      # @param [RDF::Statement]
      # @return [void]
      def insert_statement(statement)
        insert *[statement]
      end

      ##
      # Delete a single statement from this repository.
      #
      # @see RDF::Mutable#delete_statement
      # @param [RDF::Statement]
      # @return [void]
      def delete_statement(statement)
        delete *[statement]
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

      ## 
      # Serialize an RDF::Value into N-triples format.
      # Nil values will be encoded as 'nil' to avoid problems with SQL
      # implementations considering null values as distinct from one another.
      #
      # @see RDF::DataObjects::Repository#unserialize
      # @param [RDF::Value]
      # @return [String]
      def serialize(value)
        value.nil? ? 'nil' : RDF::NTriples::Writer.serialize(value)
      end

      ##
      # Unserialize an RDF::Value from N-triples format.
      # Expects nil values to be encoded as 'nil'.
      #
      # @see RDF::DataObjects::Repository#serialize
      # @param [String]
      # @return [RDF::Value]
      def unserialize(value)
        value == 'nil' ? nil : RDF::NTriples::Reader.unserialize(value)
      end
     
      ##
      # Execute the given non-query SQL with the given arguments against this
      # repository's DataObjects::Connection.
      #
      # If the given sql is in a prepared statement format, it will be executed
      # with the given *args.
      #
      # @param [String] sql
      # @param [*RDF::Value] args
      def exec(sql, *args)
        @db.create_command(sql).execute_non_query(*args)
      end

      ##
      # Execute the given query SQL with the given arguments against this
      # repository's DataObjects::Connection.
      #
      # If the given sql is in a prepared statement format, it will be executed
      # with the given *args.
      #
      # @param [String] sql
      # @param [*RDF::Value] args
      def result(sql, *args)
        @db.create_command(sql).execute_reader(*args)
      end

      ##
      # Helper method to handle the block/enumerator handling for each/each_subject/each_object, etc.
      #
      # Will call the given method with the given block is one is given.
      # Will return an enumerator with the given method called as a block if no block is given.
      #
      # @param [Symbol] method
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      # @nodoc
      # @private
      def each_or_enumerator(method, &block)
        if block_given?
          self.send(method, &block)
        else
          ::Enumerable::Enumerator.new(self,:each_or_enumerator)
        end
      end

      ##
      # Implementation of #each
      #
      # @nodoc
      # @private
      # @return [void]
      # @see RDF::Enumerable#each
      # @see RDF::DataObjects::Repository#each_or_enumerator
      def each_block(&block)
        reader = result(@adapter.each_sql)
        while reader.next!
          block.call(RDF::Statement.new(
                      :subject   => unserialize(reader.values[0]),
                      :predicate => unserialize(reader.values[1]),
                      :object    => unserialize(reader.values[2]),
                      :context   => unserialize(reader.values[3])))
        end
      end

      ##
      # Iterate over all RDF::Statements in this repository.
      #
      # @see RDF::Enumerable#each
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      def each(&block)
        each_or_enumerator(:each_block, &block)
      end

      ##
      # Iterate over all RDF::Resource subjects in this repository.
      #
      # @see RDF::Enumerable#each_subject
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      def each_subject(&block)
        each_or_enumerator(:subject_block, &block)
      end

      ##
      # Implementation of #each_subject
      #
      # @nodoc
      # @private
      # @return [void]
      # @see RDF::Enumerable#each_subject
      # @see RDF::DataObjects::Repository#each_or_enumerator
      def subject_block(&block)
        reader = result(@adapter.each_subject_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Resource predicates in this repository.
      #
      # @see RDF::Enumerable#each_predicate
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      def each_predicate(&block)
        each_or_enumerator(:predicate_block, &block)
      end

      ##
      # Implementation of #each_predicate
      #
      # @nodoc
      # @private
      # @return [void]
      # @see RDF::Enumerable#each_predicate
      # @see RDF::DataObjects::Repository#each_or_enumerator
      def predicate_block(&block)
        reader = result(@adapter.each_predicate_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Value objects in this repository.
      #
      # @see RDF::Enumerable#each_object
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      def each_object(&block)
        each_or_enumerator(:object_block, &block)
      end

      ##
      # Implementation of #each_object
      #
      # @nodoc
      # @private
      # @return [void]
      # @see RDF::Enumerable#each_object
      # @see RDF::DataObjects::Repository#each_or_enumerator
      def object_block(&block)
        reader = result(@adapter.each_object_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Resource contexts in this repository.
      #
      # @see RDF::Enumerable#each_context
      # @param [Proc] &block
      # @return [Enumerable::Enumerator, void]
      def each_context(&block)
        each_or_enumerator(:context_block, &block)
      end

      ##
      # Implementation of #each_context
      #
      # @nodoc
      # @private
      # @return [void]
      # @see RDF::Enumerable#each_context
      # @see RDF::DataObjects::Repository#each_or_enumerator
      def context_block(&block)
        reader = result(@adapter.each_context_sql)
        while reader.next!
          context = unserialize(reader.values[0])
          block.call(context) unless context.nil?
        end
      end

      ## Implementation of RDF::Queryable#query
      #  
      # This implementation will do well for statements and hashes, and not so
      # well for RDF::Query objects.
      # 
      # Accepts a query pattern argument as in RDF::Queryable.  See
      # {RDF::Queryable} for more information.
      #
      # @param [RDF::Statement, Hash, Array] pattern
      # @return [RDF::Enumerable, void]  
      # @see RDF::Queryable#query
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

      ##
      # The number of statements in this repository
      # 
      # @see RDF::Enumerable#count
      # @return [Integer]
      def count
        result = result(@adapter.count_sql)
        result.next!
        result.values.first
      end

    end
  end
end

