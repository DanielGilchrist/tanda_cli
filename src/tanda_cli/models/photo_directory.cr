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

      private def valid_photo_from_name(name : String) : Photo?
        each_photo.find { |photo| photo.path_includes?(name) && photo.valid? }
      end

      private def valid_photo : Photo?
        each_photo(shuffle: true).find(&.valid?)
      end

      private def each_photo(shuffle : Bool = false)
        Dir
          .open(@path)
          .children
          .tap { |names| names.shuffle! if shuffle }
          .each
          .map do |photo_name|
            path = path_with_dir(photo_name)
            Photo.new(path)
          end
      end

      private def path_with_dir(photo_name) : String
        "#{@path}/#{photo_name}"
      end
    end
  end
end
