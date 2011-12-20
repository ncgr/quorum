module Quorum
  module Generators
    class StylesGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/assets/stylesheets", __FILE__)
      desc "Copy quorum stylesheets to your application."

      STYLE_DIRECTORIES = [
        "quorum"
      ]

      def copy_styles
        STYLE_DIRECTORIES.each do |d|
          directory d.to_s, "app/assets/stylesheets/#{d.to_s}"
        end
      end
    end
  end
end
