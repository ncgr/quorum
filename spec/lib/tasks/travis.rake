# Travis Tasks
namespace :travis do
  # Install
  task :install do
    Rake::Task["travis:create_db_config"].execute
    Rake::Task["travis:quorum_install"].execute
    Rake::Task["travis:copy_quorum_settings"].execute
    Rake::Task["travis:create_dummy_tmp"].execute
  end

  # Remove
  task :remove do
    Rake::Task["travis:remove_db_config"].execute
    Rake::Task["travis:remove_quorum"].execute
  end

  # Specs
  task :spec do
    Rake::Task["travis:install"].execute
    ["rake spec", "rake app:jasmine:ci JASMINE_PORT=53331"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
    Rake::Task["travis:remove"].execute
  end

  # Install quorum, run migrations and prepare database.
  task :quorum_install => :environment do
    puts "Installing Quorum..."

    app_dir = Dir.getwd
    Dir.chdir(File.expand_path("../../../dummy", __FILE__))

    blastdb_dir = File.expand_path("../../../../../data/tmp", __FILE__)

    cmds = [
      "rails g quorum:install",
      "rails g quorum:views",
      "rails g quorum:styles",
      "rails g quorum:images",
      "rake quorum:install:migrations",
      "rake db:migrate",
      "rake db:test:prepare",
      "rake quorum:blastdb:build DIR=#{blastdb_dir}"
    ]
    cmds.each do |cmd|
      system("bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end

    Dir.chdir(app_dir)
  end

  # Copy quorum_settings.yml for specs.
  task :copy_quorum_settings do
    settings = File.expand_path("../../../config/quorum_settings.yml", __FILE__)
    config = File.expand_path("../../../dummy/config/quorum_settings.yml", __FILE__)
    FileUtils.copy_file(settings, config)
  end

  # Remove quorum.
  task :remove_quorum do
    dummy = File.expand_path("../../../dummy", __FILE__)
    if File.exists?(File.join(dummy, "quorum"))
      FileUtils.rm_rf File.join(dummy, "quorum")
    end
    if File.exists?(File.join(dummy, "app", "assets", "images", "quorum"))
      FileUtils.rm_rf File.join(dummy, "app", "assets", "images", "quorum")
    end
    if File.exists?(File.join(dummy, "app", "assets", "stylesheets", "quorum"))
      FileUtils.rm_rf File.join(dummy, "app", "assets", "stylesheets", "quorum")
    end
    if File.exists?(File.join(dummy, "app", "views", "layouts", "quorum"))
      FileUtils.rm_rf File.join(dummy, "app", "views", "layouts", "quorum")
    end
    if File.exists?(File.join(dummy, "app", "views", "quorum"))
      FileUtils.rm_rf File.join(dummy, "app", "views", "quorum")
    end
    if File.exists?(File.join(dummy, "quorum"))
      FileUtils.rm_rf File.join(dummy, "quorum")
    end
    if File.exists?(File.join(dummy, "config", "quorum_settings.yml"))
      FileUtils.rm File.join(dummy, "config", "quorum_settings.yml")
    end
    if File.exists?(File.join(dummy, "config", "initializers", "quorum_initializer.rb"))
      FileUtils.rm File.join(dummy, "config", "initializers", "quorum_initializer.rb")
    end
    if File.exists?(File.join(dummy, "config", "locales", "quorum.en.yml"))
      FileUtils.rm File.join(dummy, "config", "locales", "quorum.en.yml")
    end
  end

  # Create spec/dummy/config/database.yml for Travis.
  task :create_db_config do
    config = File.expand_path("../../../dummy/config", __FILE__)
    File.open(File.join(config, "database.yml"), "w+") do |file|
      file.puts "\ntest:\n  adapter: mysql2\n  encoding: utf8\n" <<
      "  reconnect: false\n  database: quorum_test\n" <<
      "  pool: 5\n  username: root\n  password:\n" <<
      "  host: localhost\n"
    end
  end

  # Remove spec/dummy/config/database.yml after Travis.
  task :remove_db_config do
    config = File.expand_path("../../../dummy/config", __FILE__)
    if File.exists?(File.join(config, "database.yml"))
      FileUtils.rm File.join(config, "database.yml")
    end
  end

  # Create tmp directory for dummy app.
  task :create_dummy_tmp do
    FileUtils.mkdir_p File.expand_path("../../../dummy", __FILE__) +
      "/tmp/" + "pids"
    FileUtils.mkdir_p File.expand_path("../../../dummy", __FILE__) +
      "/tmp/" + "cache"
  end
end
