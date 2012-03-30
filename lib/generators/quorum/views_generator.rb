module Quorum
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __FILE__)
      desc "Copy quorum views to your application."

      DIRECTORIES = [
        "quorum/jobs",
        "layouts/quorum"
      ]

      def copy_directories
        DIRECTORIES.each do |d|
          directory d.to_s, "app/views/#{d.to_s}"
        end
      end
    end
  end
end
