require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'do_sqlite3'

describe RDF::DataObjects::Repository do
  context "The SQLite adapter" do
    before :all do
      @repository = RDF::DataObjects::Repository.new "sqlite3://:memory:"
      @load_durable = lambda { RDF::DataObjects::Repository.new "sqlite3:test.db" }
    end

    after :all do
      File.delete('test.db') if File.exists?('test.db')
      @repository.close
    end

    after :each do
      DataObjects::Sqlite3::Connection.__pools.clear
      @repository.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    include RDF_Repository
  end

end
