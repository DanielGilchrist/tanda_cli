require "file_utils"

require "./abstract_file"

module TandaCLI
  module Storage
    class File < AbstractFile
      def initialize(@location : ::Path) : Nil; end

      def path : String
        @location.to_s
      end

      def exists? : Bool
        ::File.exists?(@location)
      end

      def read : String?
        return unless exists?

        ::File.read(@location)
      end

      def write(content : String) : Nil
        directory = @location.dirname
        FileUtils.mkdir_p(directory) unless ::File.directory?(directory)

        ::File.write(@location, content)
      end

      def delete! : Nil
        ::File.delete?(@location)
      end

      def delete_directory_if_empty! : Nil
        directory = @location.dirname
        ::Dir.delete(directory) if ::Dir.empty?(directory)
      end
    end
  end
end
