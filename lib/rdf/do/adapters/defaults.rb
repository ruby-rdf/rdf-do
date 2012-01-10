require 'rdf/ntriples'

module RDF::DataObjects
  module Adapters

    ## 
    # Default SQL statements and methods for RDF::DataObjects::Repository::Adapters.
    module Defaults

      def count_sql
        'select count(*) from quads'
      end

      def insert_sql
        'REPLACE INTO `quads` (subject, predicate, object, context) VALUES (?, ?, ?, ?)'
      end

      def delete_sql
        'DELETE FROM `quads` where (subject = ? AND predicate = ? AND object = ? AND context = ?)'
      end

      def each_sql
        'select * from quads'
      end

      def each_subject_sql
        'select distinct subject from quads'
      end

      def each_predicate_sql
        'select distinct predicate from quads'
      end

      def each_object_sql
        'select distinct object from quads'
      end

      def each_context_sql
        'select distinct context from quads'
      end

      ##
      # Perform a query on an RDF::DataObjects::Repository based on a hash of components.
      #
      # This is meant to be called by RDF::DataObjects::Repository.
      #
      # Supports symbols and `RDF::Query::Variable` values as a wild-card for a non-nil value.
      #
      # Supports `false` for a specifically nil value representing the default context.
      #
      # @example
      #     adapter.query(repository, :predicate => predicate)
      # @return [DataObjects::Result]
      def query(repository, hash = {})
        return repository.result(each_sql) if hash.empty?
        conditions = []
        params = []
        [:subject, :predicate, :object, :context].each do |resource|
          unless hash[resource].nil?
            if resource == :context
              case hash[resource]
              when Symbol, RDF::Query::Variable
                conditions << "#{resource.to_s} != 'nil'"
                next
              when false
                conditions << "#{resource.to_s} = 'nil'"
                next
              else
                conditions << "#{resource.to_s} = ?"
              end
            else
              conditions << "#{resource.to_s} = ?"
            end
            params     << repository.serialize(hash[resource])
          end
        end
        where = conditions.empty? ? "" : "WHERE "
        where << conditions.join(' AND ')
        puts "query: #{where.inspect}, #{params.inspect}"
        repository.result('select * from quads ' + where, *params)
      end

    end
  end
end

