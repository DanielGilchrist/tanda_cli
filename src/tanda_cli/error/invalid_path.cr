module TandaCLI
  module Error
    class InvalidPath < Error::Base
      def initialize(path)
        super("Invalid path!", "the path \"#{path}\" isn't a file or directory.")
      end
    end
  end
end
