require "./base"

module Tanda::CLI
  module Error
    class InvalidPath < Error::Base
      def initialize(path)
        super("Invalid path!", "The path \"#{path}\" can't be found.")
      end
    end
  end
end
