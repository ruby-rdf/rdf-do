$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))
$:.unshift(File.join(File.dirname(__FILE__),'..','..','rdf-spec','lib'))
$:.unshift(File.join(File.dirname(__FILE__),'..','..','rdf','lib'))

require 'rdf'
require 'rdf/spec'
require 'rdf/spec/repository'
require 'rdf/do'
require 'do_sqlite3'

describe RDF::DataObjects::Repository do
  context "The SQLite adapter" do
    before :each do
      @repository = RDF::DataObjects::Repository.new "sqlite3://:memory:"
    end

    after :each do
      @repository.clear
      DataObjects::Sqlite3::Connection.__pools.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
  end

end


