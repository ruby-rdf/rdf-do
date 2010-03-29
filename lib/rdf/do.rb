require 'data_objects'

module RDF
  module DataObjects
    class Repository

      include RDF::Enumerable, RDF::Queryable, RDF::Mutable, RDF::Durable

      def initialize(options = {})
        case options
          when String
            @db    = ::DataObjects::Connection.new(options)
          when Hash
            @db    = ::DataObjects::Connection.new(options[:db])
            schema   = options[:schema]
          when nil
            @db    = ::DataObjects::Connection.new('sqlite3://:memory:')
        end
        schema ||= :simple
        begin
          require 'rdf/do/schema/' + schema.to_s
        rescue LoadError => e
          warn "Unable to find schema '#{schema}'."
          raise e
        end
        @schema = RDF::DataObjects::Schema::const_get(schema.to_s.capitalize)
        @schema.migrate? @db
      end

      def count
        @schema.count @db        
      end

      def empty?
        count == 0
      end

      def insert(*statements)
        @schema.insert @db, *statements
      end

      def insert_statement(statement)
        insert *[statement]
      end

      def delete(*statements)
        @schema.delete @db, *statements
      end

      def delete_statement(statement)
        delete *[statement]
      end

      def each(&block)
        if block_given?
          @schema.each @db, &block
        else
          enum_statements(@schema, :each, @db)
        end
      end

      def enum_statements
        ::Enumerable::Enumerator.new(@schema, :each, db)
      end

    end
  end
end

