source "https://rubygems.org"

gemspec

gem "rdf",      git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"

group :development do
  gem "rdf-spec", git: "git://github.com/ruby-rdf/rdf-spec.git", branch: "develop"
  gem "wirble"
  gem "byebug", platforms: :mri_21
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
