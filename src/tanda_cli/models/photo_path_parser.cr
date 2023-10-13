require "../error/invalid_path"
require "./photo"
require "./photo_directory"

module TandaCLI
  module Models
    class PhotoPathParser
      def self.valid?(path : String) : Bool
        case photo_or_dir = new(path).parse
        in Photo, PhotoDirectory
          photo_or_dir.valid?
        in Error::InvalidPath
          false
        end
      end

      def initialize(@path : String)
        @path = path
      end

      def parse : Photo | PhotoDirectory | Error::InvalidPath
        if File.directory?(@path)
          PhotoDirectory.new(@path)
        elsif File.file?(@path)
          Photo.new(@path)
        else
          Error::InvalidPath.new("Invalid path: #{@path}")
        end
      end
    end
  end
end
