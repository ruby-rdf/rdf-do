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
      # @example
      #     adapter.query(repository, :predicate => predicate)
      # @return [DataObjects::Result]
      def query(repository, hash = {})
        return repository.result(each_sql) if hash.empty?
        conditions = []
        params = []
        [:subject, :predicate, :object, :context].each do |resource|
          unless hash[resource].nil?
            conditions << "#{resource.to_s} = ?"
            params     << repository.serialize(hash[resource])
          end
        end
        where = conditions.empty? ? "" : "WHERE "
        where << conditions.join(' AND ')
        repository.result('select * from quads ' + where, *params)
      end

    end
  end
end

