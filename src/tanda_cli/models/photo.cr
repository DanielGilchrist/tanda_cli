require "../error/base"
require "../error/photo_cant_be_found"
require "../error/photo_too_large"
require "../error/unsupported_photo_format"

module TandaCLI
  module Models
    class Photo
      @to_base64 : (String | Error::Base)? = nil

      ONE_MEGABYTE = 1 * 1024 * 1024

      def initialize(@path : String); end

      getter path : String

      def to_base64 : String | Error::Base
        @to_base64 ||= begin
          case photo_bytes = read_and_validate_file
          in String
            encode_base64(photo_bytes)
          in Error::Base
            photo_bytes
          end
        end
      end

      def valid? : Bool
        case to_base64
        in String
          true
        in Error::Base
          false
        end
      end

      def invalid? : Bool
        !valid?
      end

      def path_includes?(name : String) : Bool
        @path.includes?(name)
      end

      private def read_and_validate_file : String | Error::Base
        case maybe_photo_bytes = validate_file_exists || validate_file_type || read_file
        in Error::Base
          maybe_photo_bytes
        in String
          validate_photo_size(maybe_photo_bytes)
        end
      end

      private def read_file : String | Error::PhotoCantBeFound
        File.read(@path)
      rescue File::NotFoundError
        Error::PhotoCantBeFound.new(@path)
      end

      private def validate_file_type : Error::UnsupportedPhotoFormat?
        return if jpeg? || png?

        Error::UnsupportedPhotoFormat.new
      end

      private def validate_file_exists : Error::PhotoCantBeFound?
        return if File.exists?(@path)

        Error::PhotoCantBeFound.new(@path)
      end

      private def validate_photo_size(photo_bytes : String) : String | Error::PhotoTooLarge
        if photo_bytes.bytesize <= ONE_MEGABYTE
          photo_bytes
        else
          Error::PhotoTooLarge.new(photo_bytes)
        end
      end

      private def encode_base64(photo_bytes : String) : String | Error::UnsupportedPhotoFormat
        if jpeg?
          "data:image/jpeg;base64,#{Base64.strict_encode(photo_bytes)}"
        elsif png?
          "data:image/png;base64,#{Base64.strict_encode(photo_bytes)}"
        else
          Error::UnsupportedPhotoFormat.new
        end
      end

      private def jpeg? : Bool
        @path.ends_with?(".jpg") || @path.ends_with?(".jpeg")
      end

      private def png? : Bool
        @path.ends_with?(".png")
      end
    end
  end
end
