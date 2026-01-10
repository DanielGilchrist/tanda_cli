module TandaCLI
  module Error
    class PhotoCantBeFound < Error::Base
      def initialize(path : String)
        super("Photo can't be found", "the file '#{path}' could not be found.")
      end
    end
  end
end
