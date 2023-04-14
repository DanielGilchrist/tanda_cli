require "./photo"

module Tanda::CLI
  module Models
    class PhotoDirectory
      def initialize(@path : String); end

      def sample_photo : Photo?
        valid_photo.tap do |photo|
          Utils::Display.warning("No valid photos found in #{@path}") if photo.nil?
        end
      end

      private def valid_photo : Photo?
        valid_photo : Photo? = nil

        Dir.open(@path).children.shuffle.each do |photo_name|
          path = path_with_dir(photo_name)
          photo = Photo.new(path)

          break valid_photo = photo if photo.valid?
        end

        valid_photo
      end

      private def path_with_dir(photo_name) : String
        "#{@path}/#{photo_name}"
      end
    end
  end
end
