module Quorum
  module Generators
    class ImagesGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/assets/images", __FILE__)
      desc "Copy quorum images to your application."

      IMAGE_DIRECTORIES = [
        "quorum"
      ]

      def copy_images
        IMAGE_DIRECTORIES.each do |d|
          directory d.to_s, "app/assets/images/#{d.to_s}"
        end
      end
    end
  end
end
