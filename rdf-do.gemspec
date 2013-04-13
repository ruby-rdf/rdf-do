#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-do'
  gem.homepage           = 'http://ruby-rdf.github.com/rdf-do'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.description        = 'RDF.rb plugin providing a DataObjects storage adapter.'
  gem.summary            = 'RDF.rb plugin providing a DataObjects storage adapter.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Ben Lavender']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.9.2'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',          '>= 1.1.0'
  gem.add_runtime_dependency     'data_objects', '>= 0.10.11'
  gem.add_development_dependency 'do_sqlite3' ,  '>= 0.10.11'
  gem.add_development_dependency 'do_postgres' , '>= 0.10.11'
  gem.add_development_dependency 'rdf-spec',     '>= 1.1.0'
  gem.add_development_dependency 'rspec',        '>= 2.12.0'
  gem.add_development_dependency 'yard' ,        '>= 0.8.3'
  gem.post_install_message       = nil
end
