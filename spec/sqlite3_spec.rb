require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'do_sqlite3'

describe RDF::DataObjects::Repository do
  context "The SQLite adapter" do
    let(:repository) {RDF::DataObjects::Repository.new uri: "sqlite3://:memory:"}

    before(:each) {@load_durable = lambda { RDF::DataObjects::Repository.new uri: "sqlite3:test.db" }}
    after(:all) {File.delete('test.db') if File.exists?('test.db')}
    after(:each) {DataObjects::Sqlite3::Connection.__pools.clear}

    it_behaves_like "an RDF::Repository"

    context "problematic examples" do
      Dir.glob(File.expand_path("../datafiles/*.nt", __FILE__)).each do |f|
        it "loads #{f}" do
          count = File.readlines(f).length
          expect {repository.load(f)}.to change {repository.count}.from(0).to(count)
        end
      end
    end
  end
end
