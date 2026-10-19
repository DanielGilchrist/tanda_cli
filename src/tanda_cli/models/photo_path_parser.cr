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

      def initialize(@path : String) : Nil
      end

      def parse : Photo | PhotoDirectory | Error::InvalidPath
        expanded_path = Path.new(@path).expand(home: true).to_s

        if File.directory?(expanded_path)
          PhotoDirectory.new(expanded_path)
        elsif File.file?(expanded_path)
          Photo.new(expanded_path)
        else
          Error::InvalidPath.new(@path)
        end
      end
    end
  end
end
