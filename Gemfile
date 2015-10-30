source "https://rubygems.org"

gemspec

gem "rdf",      git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"

group :development do
  gem "rdf-spec", git: "git://github.com/ruby-rdf/rdf-spec.git", branch: "develop"
end

group :debug do
  gem 'shotgun'
  gem "wirble"
  gem "debugger", platforms: :mri_19
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
