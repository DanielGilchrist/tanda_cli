module Tanda::CLI
  module Models
    class Photo
      @base_64_encoded : (String | Error::Base)? = nil

      ONE_MEGABYTE = 1 * 1024 * 1024

      module Error
        abstract class Base < Exception; end

        class PhotoCantBeFound < Base
          def initialize(path : String)
            @message = "The file '#{path}' could not be found."
          end
        end

        class PhotoTooLarge < Base
          def initialize(photo_bytes : String)
            @message = "Photo is over 1 MB (#{photo_bytes.bytesize} bytes)"
          end
        end

        class UnsupportedPhotoFormat < Base
          def initialize
            @message = "Photo must be a JPEG or PNG."
          end
        end
      end

      def initialize(@path : String); end

      def base_64_encoded : String | Error::Base
        @base_64_encoded ||= begin
          photo_bytes = read_and_validate_file
          if photo_bytes.is_a?(Error::Base)
            photo_bytes
          else
            encode_base_64(photo_bytes)
          end
        end
      end

      def valid? : Bool
        base_64_encoded.is_a?(String)
      end

      private getter path : String

      private def read_and_validate_file : String | Error::Base
        photo_bytes = validate_file_exists || validate_file_type || read_file
        return photo_bytes unless photo_bytes.is_a?(String)

        validate_photo_size(photo_bytes) || photo_bytes
      end

      private def read_file : String | Error::PhotoCantBeFound
        File.read(path)
      rescue File::NotFoundError
        Error::PhotoCantBeFound.new(path)
      end

      private def validate_file_type : Error::UnsupportedPhotoFormat?
        return if jpeg? || png?

        Error::UnsupportedPhotoFormat.new
      end

      private def validate_file_exists : Error::PhotoCantBeFound?
        return if File.exists?(path)

        Error::PhotoCantBeFound.new(path)
      end

      private def validate_photo_size(photo_bytes : String) : Error::Base?
        return if photo_bytes.bytesize <= ONE_MEGABYTE

        Error::PhotoTooLarge.new(photo_bytes)
      end

      private def encode_base_64(photo_bytes : String) : String | Error::Base
        if jpeg?
          "data:image/jpeg;base64,#{Base64.strict_encode(photo_bytes)}"
        elsif png?
          "data:image/png;base64,#{Base64.strict_encode(photo_bytes)}"
        else
          Error::UnsupportedPhotoFormat.new
        end
      end

      private def jpeg? : Bool
        path.ends_with?(".jpg") || path.ends_with?(".jpeg")
      end

      private def png? : Bool
        path.ends_with?(".png")
      end
    end
  end
end
