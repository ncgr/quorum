# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_girl'
require 'database_cleaner'
require 'resque_spec'

FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.find_definitions

ENGINE_RAILS_ROOT = File.expand_path("../../", __FILE__)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.include Capybara::DSL, :example_group => { :file_path => /\bspec\/requests\// }

  # This will include the routing helpers in the specs so that we can use
  # quorum_path, etc., to get to the routes.
  config.include Quorum::Engine.routes.url_helpers

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  ## DatabaseCleaner ##
  DatabaseCleaner.logger = Rails.logger
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  ## Redis ##
  REDIS_PID        = File.expand_path("../dummy/tmp/pids/redis-test.pid", __FILE__)
  REDIS_CACHE_PATH = File.expand_path("../dummy/tmp/cache/", __FILE__)

  config.before(:suite) do
    redis_options = {
      "daemonize"     => "yes",
      "pidfile"       => REDIS_PID,
      "port"          => 9736,
      "timeout"       => 300,
      "save 900"      => 1,
      "save 300"      => 1,
      "save 60"       => 10000,
      "dbfilename"    => "dump.rdb",
      "dir"           => REDIS_CACHE_PATH,
      "loglevel"      => "debug",
      "logfile"       => "stdout",
      "databases"     => 16
    }.map { |k, v| "#{k} #{v}" }.join('
                                      ')
    `echo '#{redis_options}' | redis-server -`
  end

  config.after(:suite) do
    %x{
      cat #{REDIS_PID} | xargs kill -QUIT
      rm -f #{REDIS_CACHE_PATH}dump.rdb
    }
  end
end
