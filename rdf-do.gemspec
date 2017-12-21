#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-do'
  gem.homepage           = 'http://ruby-rdf.github.com/rdf-do'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.description        = 'RDF.rb extension providing a DataObjects storage adapter.'
  gem.summary            = 'RDF.rb extension providing a DataObjects storage adapter.'

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

  gem.required_ruby_version      = '>= 2.2.2'
  gem.requirements               = []
  #gem.add_runtime_dependency     'rdf',          '~> 3.0'
  gem.add_runtime_dependency     'rdf',          '>= 2.2', '< 4.0'
  gem.add_runtime_dependency     'data_objects', '~> 0.10'
  gem.add_development_dependency 'do_sqlite3' ,  '~> 0.10'
  gem.add_development_dependency 'do_postgres' , '~> 0.10'
  #gem.add_development_dependency 'rdf-spec',     '~> 2.2'
  gem.add_development_dependency 'rdf-spec',     '>= 2.2', '< 4.0'
  gem.add_development_dependency 'rspec',        '~> 3.7'
  gem.add_development_dependency 'rspec-its',    '~> 1.2'
  gem.add_development_dependency 'yard' ,        '~> 0.9.12'

  gem.post_install_message       = nil
end
