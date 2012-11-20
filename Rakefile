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

Bundler::GemHelper.install_tasks

# Travis tasks
load 'spec/lib/tasks/travis.rake'

# Spec runner
task :spec_runner => :environment do
  unless File.exists?(File.expand_path("../spec/dummy/quorum", __FILE__))
    Rake::Task["travis:quorum_install"].execute
    Rake::Task["travis:copy_quorum_settings"].execute
  end
  unless File.exists?(File.expand_path("../spec/dummy/tmp", __FILE__))
    Rake::Task["travis:create_dummy_tmp"].execute
  end
  Rake::Task["spec"].execute
  Rake::Task["app:jasmine:ci"].execute
end

task :default => :spec_runner
