#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-do'
  gem.homepage           = 'https://ruby-rdf.github.com/rdf-do'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.description        = 'RDF.rb extension providing a DataObjects storage adapter.'
  gem.summary            = 'RDF.rb extension providing a DataObjects storage adapter.'

  gem.authors            = ['Ben Lavender']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CHANGELOG CONTRIBUTING.md README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)

  gem.required_ruby_version      = '>= 2.4'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',          '~> 3.1'
  gem.add_runtime_dependency     'data_objects', '~> 0.10'
  gem.add_development_dependency 'do_sqlite3' ,  '~> 0.10'
  gem.add_development_dependency 'do_postgres' , '~> 0.10'
  gem.add_development_dependency 'rdf-spec',     '~> 3.1'
  gem.add_development_dependency 'rspec',        '~> 3.9'
  gem.add_development_dependency 'rspec-its',    '~> 1.3'
  gem.add_development_dependency 'yard' ,        '~> 0.9'

  gem.post_install_message       = nil
end
