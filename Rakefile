require 'rubygems'
require 'spec'
require 'spec/rake/spectask'

desc 'Run specs'
task 'spec' do
  Spec::Rake::SpecTask.new("spec") do |t|
    t.spec_files = FileList["spec/*.spec","spec/*.rb"]
    t.rcov = true
    t.spec_opts = ["-c"]
  end
end

desc 'Run specs with backtrace'
task 'tracespec' do
  Spec::Rake::SpecTask.new("tracespec") do |t|
    t.spec_files = FileList["spec/*.spec"]
    t.rcov = false
    t.spec_opts = ["-bcfn"]
  end
end

desc 'Run sqlite3 specs'
task 'sqlite' do
  Spec::Rake::SpecTask.new("sqlite") do |t|
    t.spec_files = FileList["spec/sqlite3.spec"]
    t.spec_opts = ["-bcfn"]
  end
end

desc 'Run postgres specs'
task 'pg' do
  Spec::Rake::SpecTask.new("pg") do |t|
    t.spec_files = FileList["spec/postgres.spec"]
    t.spec_opts = ["-bcfn"]
  end
end

desc "Open an irb session with everything loaded, including test fixtures"
task :console do
  sh "irb -rubygems -I lib -r rdf-do"
end

task :default => [:spec]
