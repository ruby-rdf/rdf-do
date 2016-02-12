source "https://rubygems.org"

gemspec

gem "rdf",      github: "ruby-rdf/rdf", branch: "develop"

group :development do
  gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
  gem "rdf-spec",       github: "ruby-rdf/rdf-spec",        branch: "develop"
  gem "wirble"
  gem "byebug", platforms: :mri
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
