require "./abstract_file"

module TandaCLI
  module Storage
    class InheritingFile < AbstractFile
      def initialize(@file : AbstractFile, @inherits_from : AbstractFile) : Nil; end

      def path : String
        @file.path
      end

      def read : String?
        @file.read.presence || @inherits_from.read
      end

      def write(content : String) : Nil
        @file.write(content)
      end
    end
  end
end
