module Quorum
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Quorum initializer, quorum_settings.yml and " <<
           "executable files."

      def copy_initializer
        template "quorum_initializer.rb", 
          "config/initializers/quorum_initializer.rb"
        template "quorum_settings.yml", "config/quorum_settings.yml"
        template "quorum", "quorum/bin/quorum"
      end

      def change_file_permissions
        f = File.new("quorum/bin/quorum", "r")
        f.chmod(0755)
      end

      def add_mount_engine
        route %Q(mount Quorum::Engine => "/quorum")
      end

      def show_readme
        readme "README"
      end
    end
  end
end
