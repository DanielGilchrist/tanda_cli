require "./photo"

module Tanda::CLI
  module Models
    class PhotoDirectory
      def initialize(@path : String); end

      def valid? : Bool
        Dir.exists?(@path) && !!valid_photo
      end

      def sample_photo : Photo?
        valid_photo.tap do |photo|
          Utils::Display.warning("No valid photos found in #{@path}") if photo.nil?
        end
      end

      private def valid_photo : Photo?
        Dir
          .open(@path)
          .children
          .shuffle
          .each
          .map do |photo_name|
            path = path_with_dir(photo_name)
            Photo.new(path)
          end
          .find(&.valid?)
      end

      private def path_with_dir(photo_name) : String
        "#{@path}/#{photo_name}"
      end
    end
  end
end
