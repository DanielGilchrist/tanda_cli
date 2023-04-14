require "./photo"
require "./photo_directory"

module Tanda::CLI
  module Models
    class PhotoParser
      class InvalidPath < Exception
        def initialize(@message : String); end
      end

      def initialize(@path : String)
        @path = path
      end

      def parse : Photo | PhotoDirectory | InvalidPath
        if File.directory?(@path)
          PhotoDirectory.new(@path)
        elsif File.file?(@path)
          Photo.new(@path)
        else
          InvalidPath.new("Invalid path: #{@path}")
        end
      end
    end
  end
end
