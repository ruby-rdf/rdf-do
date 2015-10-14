require 'rubygems'
require 'rspec/core/rake_task'
require 'yard'

namespace :gem do
  desc "Build the rdf-do-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build rdf-do.gemspec && mv rdf-do-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the rdf-do-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/rdf-do-#{File.read('VERSION').chomp}.gem"
  end
end

RSpec::Core::RakeTask.new(:spec)

desc "Run specs through RCov"
RSpec::Core::RakeTask.new("spec:rcov") do |spec|
  spec.rcov = true
  spec.rcov_opts =  %q[--exclude "spec"]
end
task default: [:spec]
