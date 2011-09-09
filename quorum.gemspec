$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quorum/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quorum"
  s.version     = Quorum::VERSION
  s.authors     = ["Ken Seal"]
  s.email       = ["kas@ncgr.org"]
  s.homepage    = "https://github.com/hunzinker/quorum"
  s.summary     = "Flexible bioinformatics search tool."
  s.description = "Flexible bioinformatics search tool."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_girl_rails"
end
