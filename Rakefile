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

namespace :travis do
  # Specs
  task :spec do
    ["rake spec", "rake app:jasmine:ci"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
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
end
