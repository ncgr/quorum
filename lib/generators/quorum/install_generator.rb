module Quorum
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates Quorum initializer, settings and " <<
           "search tool files."

      DEPENDENCIES = ["makeblastdb", "seqret"]

      def copy_initializer
        template "quorum_initializer.rb", 
          "config/initializers/quorum_initializer.rb"
        template "quorum_settings.yml", "config/quorum_settings.yml"
        template "search", "quorum/bin/search"
        template "trollop.rb", "quorum/lib/trollop.rb"
        template "logger.rb", "quorum/lib/logger.rb"
        template "blast.rb", "quorum/lib/search_tools/blast.rb"
        template "hmmer.rb", "quorum/lib/search_tools/hmmer.rb"
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/quorum.en.yml"
      end

      def change_file_permissions
        f = File.new("quorum/bin/search", "r")
        f.chmod(0755)
      end

      def create_quorum_tmp_dir
        Dir.mkdir("quorum/tmp") unless File.directory?("quorum/tmp")
      end

      def create_quorum_log_dir
        Dir.mkdir("quorum/log") unless File.directory?("quorum/log")
      end

      def add_mount_engine
        route %Q(mount Quorum::Engine => "/quorum")
      end

      def add_resque_mount_engine
        route %Q(mount Resque::Server.new, :at => "/quorum/resque")
      end

      def check_dependencies
        puts "Checking Quorum system dependencies..."
        messages = []
        DEPENDENCIES.each do |b|
          system("which #{b} 2>&1 /dev/null")
          if $?.exitstatus > 0
            messages << "Quorum dependency not found. " <<
            "Please add `#{b}` to your PATH."
          end
        end
        unless messages.empty?
          puts "*** Warning: Quorum system dependencies not found ***"
          puts messages.join('\n')
        end
      end

      def show_readme
        readme "README"
      end

    end
  end
end
