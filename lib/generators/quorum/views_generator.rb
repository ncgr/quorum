module Quorum
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views/quorum", __FILE__)
      desc "Copy quorum views to your application."

      VIEW_DIRECTORIES = [
        "jobs"
      ]

      def copy_views
        VIEW_DIRECTORIES.each do |d|
          directory d.to_s, "app/views/quorum/#{d.to_s}"
        end
      end

    end
  end
end
