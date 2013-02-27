$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quorum/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quorum"
  s.version     = Quorum::VERSION
  s.authors     = ["Ken Seal"]
  s.email       = ["kas@ncgr.org"]
  s.homepage    = "https://github.com/ncgr/quorum"
  s.summary     = "Flexible bioinformatics search tool."
  s.description = "Flexible bioinformatics search tool."

  s.files = `git ls-files`.split(/\n/)

  s.add_dependency "rails", "~> 3.1"
  s.add_dependency "jquery-rails"
  s.add_dependency "net-ssh", "~> 2.3"
  s.add_dependency "resque", "~> 1.20"
  s.add_dependency "resque-result", "~> 1.0.1"
  s.add_dependency "bio-blastxmlparser", "~> 1.1.1"

  s.add_development_dependency "mysql2", "~> 0.3.11"
  s.add_development_dependency "pg", "~> 0.14.1"
  s.add_development_dependency "rspec-rails", "~> 2.11"
  s.add_development_dependency "resque_spec", "~> 0.12"
  s.add_development_dependency "capybara", "~> 1.1"
  s.add_development_dependency "database_cleaner", "~> 0.8"
  s.add_development_dependency "jasmine", "1.3.0"
end
