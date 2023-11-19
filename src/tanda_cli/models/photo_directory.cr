require "./photo"

module TandaCLI
  module Models
    class PhotoDirectory
      def initialize(@path : String); end

      def valid? : Bool
        Dir.exists?(@path) && !!valid_photo
      end

      def find_photo(name : String) : Photo?
        valid_photo_from_name(name).tap do |photo|
          Utils::Display.warning("No valid photo in #{@path} matching #{name}") if photo.nil?
        end
      end

      def sample_photo : Photo?
        valid_photo.tap do |photo|
          Utils::Display.warning("No valid photos found in #{@path}") if photo.nil?
        end
      end

      private def valid_photo_from_name(name : String)
        photo_names
          .each
          .map do |photo_name|
            path = path_with_dir(photo_name)
            Photo.new(path)
          end
          .find { |photo| (photo == name || photo.path_includes?(name)) && photo.valid? }
      end

      private def valid_photo : Photo?
        photo_names
          .shuffle
          .each
          .map do |photo_name|
            path = path_with_dir(photo_name)
            Photo.new(path)
          end
          .find(&.valid?)
      end

      private def photo_names : Array(String)
        Dir.open(@path).children
      end

      private def path_with_dir(photo_name) : String
        "#{@path}/#{photo_name}"
      end
    end
  end
end
