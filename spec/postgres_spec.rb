require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'do_postgres'

describe RDF::DataObjects::Repository do
  if ENV['DATABASE_URL']
    context "The Postgres adapter" do
      let(:repository) {@load_durable.call}

      before(:each) do
        @load_durable = lambda { RDF::DataObjects::Repository.new(uri: ENV['DATABASE_URL']) }
      end

      before :each do
        @load_durable = RDF::DataObjects::Repository.new(uri: ENV['DATABASE_URL'])
      end

      after :each do
        repository.clear
        repository.close
        DataObjects::Pooling.pools.each {|pool| pool.dispose}
      end

      it_behaves_like "an RDF::Repository"
    end
  else
    warn "Skipping postgres tests; no DATABASE_URL found."
  end
end


