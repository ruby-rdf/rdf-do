$:.unshift(File.join(File.dirname(__FILE__),'..','lib'))
$:.unshift(File.join(File.dirname(__FILE__),'..','..','rdf-spec','lib'))
$:.unshift(File.join(File.dirname(__FILE__),'..','..','rdf','lib'))

require 'rdf'
require 'rdf/spec'
require 'rdf/spec/repository'
require 'rdf/do'
require 'do_postgres'

describe RDF::DataObjects::Repository do
  if ENV['DATABASE_URL']
    context "The Postgres adapter" do
    before :each do
      @repository = RDF::DataObjects::Repository.new ENV['DATABASE_URL']
    end

    after :each do
      DataObjects::Pooling.pools.each {|pool| pool.dispose}
      #DataObjects::Postgres::Connection.__pools.clear
      @repository.clear
      #@repository.dispose
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
      


    end
  else
    warn "Skipping postgres tests; no DATABASE_URL found."
  end
end


