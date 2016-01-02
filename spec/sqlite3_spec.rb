require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'do_sqlite3'

describe RDF::DataObjects::Repository do
  context "The SQLite adapter" do
    let(:repository) {RDF::DataObjects::Repository.new "sqlite3://:memory:"}
    before :all do
      @load_durable = lambda { RDF::DataObjects::Repository.new "sqlite3:test.db" }
    end
  
    after :all do
      File.delete('test.db') if File.exists?('test.db')
    end
  
    after :each do
      DataObjects::Sqlite3::Connection.__pools.clear
    end
  
    it_behaves_like "an RDF::Repository"

    context "problematic examples" do
      Dir.glob(File.expand_path("../datafiles/*.nt", __FILE__)).each do |f|
        it "loads #{f}" do
          repo = @load_durable.call
          repo.clear
          count = File.readlines(f).length
          expect {repo.load(f)}.to change {repo.count}.from(0).to(count)
        end
      end
    end
  end
end
