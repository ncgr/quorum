module Quorum
  module Generators
    class InstallGenerator < Rails::Generators::Base

      include Quorum::Helpers::Colors

      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates Quorum initializer, settings and search " <<
           "/ fetch tool files."

      DEPENDENCIES = ["gmap_build", "makeblastdb", "seqret"]

      def copy_quorum
        template "quorum_initializer.rb",
          "config/initializers/quorum_initializer.rb"
        template "quorum_settings.yml", "config/quorum_settings.yml"
        template "search", "quorum/bin/search"
        template "fetch", "quorum/bin/fetch"
        template "trollop.rb", "quorum/lib/trollop.rb"
        template "logger.rb", "quorum/lib/logger.rb"
        template "blast.rb", "quorum/lib/search_tools/blast.rb"
        template "gmap.rb", "quorum/lib/search_tools/gmap.rb"
        template "blast_db.rb", "quorum/lib/fetch_tools/blast_db.rb"
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/quorum.en.yml"
      end

      def change_file_permissions
        Dir.glob(File.join("quorum", "bin", "*")).each do |f|
          File.new(f, "r").chmod(0755)
        end
      end

      def create_quorum_tmp_dir
        Dir.mkdir("quorum/tmp") unless File.directory?("quorum/tmp")
      end

      def create_quorum_log_dir
        Dir.mkdir("quorum/log") unless File.directory?("quorum/log")
      end

      def set_mount_engines
        @quorum = %Q(mount Quorum::Engine => "/quorum")
        @resque = %Q(mount Resque::Server.new, :at => "/quorum/resque")
      end

      def read_routes_file
        @routes = File.open(File.join("config", "routes.rb"), "r")
        @routes = @routes.read
      end

      def mount_engine_exists?
        @routes.include?(@quorum)
      end

      def add_mount_engine
        route @quorum unless mount_engine_exists?
      end

      def resque_mount_engine_exists?
        @routes.include?(@resque)
      end

      def add_resque_mount_engine
        route @resque unless resque_mount_engine_exists?
      end

      def check_dependencies
        puts ""
        puts "Checking Quorum system dependencies..."
        messages = []
        DEPENDENCIES.each do |b|
          system("which #{b} > /dev/null 2>&1")
          messages << b if $?.exitstatus > 0
        end
        unless messages.empty?
          puts bold(
            red("*** Warning: Quorum system dependencies not found ***")
          )
          puts bold(
            red("Please add the below to your PATH.")
          )
          messages.each { |m| puts bold(red(m)) }
        else
          puts "All good! Yay!!"
        end
      end

      def show_readme
        readme "README"
      end
    end
  end
end
