require 'data_objects'
require 'rdf'
require 'rdf/ntriples'
require 'enumerator'
require 'rdf/do/version'

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

      ##
      # Initializes this repository instance.
      # 
      # @example
      #     RDF::DataObjects::Repository.new  # => new Repository based on sqlite3://:memory:
      #     RDF::DataObjects::Repository.new uri: 'postgres://localhost/database'
      #       => New repository based on postgres adapter
      #
      # @param  [Hash{Symbol => Object}] options
      # @option options [URI, #to_s]    :uri (nil)
      # @option options [String, #to_s] :title (nil)
      # @option options [String, #to_s] :adaptor (nil)
      #   The default adapter will be loaded based on the URI
      #   scheme of the created connection.
      # @option options [String] :db Synonym for :uri
      # @return [RDF::DataObjects::Repository]
      def initialize(options = {}, &block)
        warn "[DEPRECATION] RDF::DataObjects::Repository#initialize expects a uri argument. Called from #{Gem.location_of_caller.join(':')}" unless options.is_a?(Hash)
        options = {uri: options.to_s} unless options.is_a?(Hash)
        db = options[:uri] || options[:db] || 'sqlite3://:memory:'
        @db = ::DataObjects::Connection.new(db)

        adapter = options[:adapter] || @db.instance_variable_get("@uri").scheme
        require 'rdf/do/adapters/' + adapter.to_s

        @adapter = RDF::DataObjects::Adapters::const_get(adapter.to_s.capitalize)
        @adapter.migrate? self
        super(options, &block)
      rescue Exception => e
        raise LoadError, "Could not load a DataObjects adapter for #{options}.  You may need to add a 'require do_adapter', or you may be trying to use an unsupported adapter (Currently supporting postgres, sqlite3).  The error message was: #{e.message}"
      end

      # @see RDF::Mutable#insert_statement
      def supports?(feature)
        case feature.to_sym
          when :graph_name then true
          else false
        end
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
      # @param [RDF::Statement] statement
      # @return [void]
      def insert_statement(statement)
        raise ArgumentError, "Statement #{statement.inspect} is incomplete" if statement.incomplete?
        insert_statements [statement]
      end

      ##
      # Delete a single statement from this repository.
      #
      # @see RDF::Mutable#delete_statement
      # @param [RDF::Statement] statement
      # @return [void]
      def delete_statement(statement)
        query = @adapter.delete_sql
        exec(query, serialize(statement.subject), serialize(statement.predicate), serialize(statement.object), serialize(statement.graph_name)) 
      end

      ##
      # Insert multiple statements into this repository
      #
      # @see RDF::Mutable#insert_statements
      # @param  [Array<RDF::Statement>] statements
      # @return [void]
      def insert_statements(statements)
        raise ArgumentError, "Some statement is incomplete" if statements.any?(&:incomplete?)
        if @adapter.respond_to?(:multiple_insert_sql)
          each = statements.respond_to?(:each_statement) ? :each_statement : :each
          args = []
          count = 0
          statements.__send__(each) do |s|
            count += 1
            args += [serialize(s.subject),serialize(s.predicate), serialize(s.object), serialize(s.graph_name)]
          end
          query = @adapter.multiple_insert_sql(count)
          exec(query,*(args.flatten))
        else
          query = @adapter.insert_sql
          each = statements.respond_to?(:each_statement) ? :each_statement : :each
          statements.__send__(each) do |s|
            exec(query, serialize(s.subject),serialize(s.predicate), serialize(s.object), serialize(s.graph_name)) 
          end
        end
      end

      ## 
      # Serialize an RDF::Value into N-triples format.
      # Nil values will be encoded as 'nil' to avoid problems with SQL
      # implementations considering null values as distinct from one another.
      #
      # @see RDF::DataObjects::Repository#unserialize
      # @param [RDF::Value] value
      # @return [String]
      def serialize(value)
        value.nil? ? 'nil' : RDF::NTriples::Writer.serialize(value)
      end

      ##
      # Unserialize an RDF::Value from N-triples format.
      # Expects nil values to be encoded as 'nil'.
      #
      # @see RDF::DataObjects::Repository#serialize
      # @param [String] value
      # @return [RDF::Value]
      def unserialize(value)
        result = value == 'nil' ? nil : RDF::NTriples::Reader.unserialize(value)
        case result
        when RDF::URI
          RDF::URI.intern(result)
        when RDF::Node
          # This should probably be done in RDF::Node.intern
          id = result.id.to_s
          @nodes ||= {}
          @nodes[id] ||= RDF::Node.new(id)
        else
          result
        end
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
        @nodes = {} # reset cache. FIXME this should probably be in Node.intern
        @db.create_command(sql).execute_reader(*args)
      end

      ##
      # Iterate over all RDF::Statements in this repository.
      #
      # @see RDF::Enumerable#each
      # @yield statement
      # @yieldparam [RDF::Statement] statement
      # @return [Enumerable::Enumerator, void]
      def each(&block)
        return enum_for(:each) unless block_given?
        reader = result(@adapter.each_sql)
        while reader.next!
          block.call(RDF::Statement.new(
                     subject:    unserialize(reader.values[0]),
                     predicate:  unserialize(reader.values[1]),
                     object:     unserialize(reader.values[2]),
                     graph_name: unserialize(reader.values[3])))
        end
      end

      ##
      # Iterate over all RDF::Resource subjects in this repository.
      #
      # @see RDF::Enumerable#each_subject
      # @yield subject
      # @yieldparam [RDF::Resource] subject
      # @return [Enumerable::Enumerator, void]
      def each_subject(&block) 
        return enum_for(:each_subject) unless block_given?
        reader = result(@adapter.each_subject_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Resource predicates in this repository.
      #
      # @see RDF::Enumerable#each_predicate
      # @yield predicate
      # @yieldparam [RDF::Resource] predicate
      # @return [Enumerable::Enumerator, void]
      def each_predicate(&block)
        return enum_for(:each_predicate) unless block_given?
        reader = result(@adapter.each_predicate_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Value objects in this repository.
      #
      # @see RDF::Enumerable#each_object
      # @yield object
      # @yieldparam [RDF::Resource] object
      # @return [Enumerable::Enumerator, void]
      def each_object(&block)
        return enum_for(:each_object) unless block_given?
        reader = result(@adapter.each_object_sql)
        while reader.next!
          block.call(unserialize(reader.values[0]))
        end
      end

      ##
      # Iterate over all RDF::Resource graph names in this repository.
      #
      # @see RDF::Enumerable#each_graph
      # @yield graph
      # @yieldparam [RDF::Graph] graph
      # @return [Enumerable::Enumerator, void]
      def each_graph(&block)
        return enum_for(:each_graph) unless block_given?

        reader = result(@adapter.each_graph_sql)
        while reader.next!
          graph_name = unserialize(reader.values[0])
          yield RDF::Graph.new(graph_name: graph_name, data: self)
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

      protected

      ##
      # Implementation of RDF::Queryable#query_pattern
      #  
      # This implementation will do well for statements and hashes, and not so
      # well for RDF::Query objects.
      # 
      # Accepts a query pattern argument as in RDF::Queryable.  See
      # {RDF::Queryable} for more information.
      #
      # @param [RDF::Query::Pattern] pattern
      # @see RDF::Queryable#query_pattern
      # @see RDF::Query::Pattern
      def query_pattern(pattern, options = {}, &block)
        return enum_for(:query_pattern, pattern, options) unless block_given?
        @nodes = {} # reset cache. FIXME this should probably be in Node.intern
        reader = @adapter.query(self, pattern.to_h)
        while reader.next!
          yield RDF::Statement.new(
              subject:    unserialize(reader.values[0]),
              predicate:  unserialize(reader.values[1]),
              object:     unserialize(reader.values[2]),
              graph_name: unserialize(reader.values[3]))
        end
      end

    end
  end
end

