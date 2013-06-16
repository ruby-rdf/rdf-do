require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'do_postgres'

describe RDF::DataObjects::Repository do
  if ENV['DATABASE_URL']
    context "The Postgres adapter" do
      before :all do
        @load_durable = @repository = RDF::DataObjects::Repository.new ENV['DATABASE_URL']
        @repository.clear
      end

      after :all do
        @repository.close
        DataObjects::Pooling.pools.each {|pool| pool.dispose}
      end

      after :each do
        DataObjects::Pooling.pools.each {|pool| pool.dispose}
        @repository.clear
      end

      # @see lib/rdf/spec/repository.rb in RDF-spec
      include RDF_Repository
    end
  else
    warn "Skipping postgres tests; no DATABASE_URL found."
  end
end


