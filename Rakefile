#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Quorum'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

Bundler::GemHelper.install_tasks

# Travis Tasks
namespace :travis do
  port = 53331

  # Specs
  task :spec do
    Rake::Task["travis:create_dirs"].execute
    ["rake spec", "rake app:jasmine:ci JASMINE_PORT=#{port}"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:#{port}.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
    Rake::Task["travis:remove_db_config"].execute
  end

  # Create spec/dummy/config/database.yml for Travis.
  task :create_db_config do
    config = File.expand_path("../spec/dummy/config", __FILE__)
    File.open(File.join(config, "database.yml"), "w+") do |file|
      file.puts "test:\n  adapter: mysql2\n  database: quorum_test\n" <<
      "  username: root\n  password:\n  host: localhost\n  encoding: utf8"
    end
  end

  # Remove spec/dummy/config/database.yml after Travis.
  task :remove_db_config do
    config = File.expand_path("../spec/dummy/config", __FILE__)
    File.delete(File.join(config, "database.yml"))
  end

  # Create necessary directories for test. Mimic a real app install
  # via rails g quorum:install.
  #
  # The directories below are not in the git repo.
  task :create_dirs do
    app    = File.expand_path("../spec/dummy", __FILE__)
    quorum = File.expand_path("../spec/dummy/quorum", __FILE__)

    Dir.mkdir(File.join(app, "tmp"))
    Dir.mkdir(File.join(app, "tmp", "pids"))
    Dir.mkdir(File.join(app, "tmp", "cache"))
    Dir.mkdir(File.join(quorum, "log"))
    Dir.mkdir(File.join(quorum, "tmp"))
  end
end
