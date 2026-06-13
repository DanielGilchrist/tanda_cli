require "./base"

module Kebab
  module Error
    class MissingArgument < Error::Base
      def initialize(name : String)
        super("Missing argument!", "\"#{name}\" is required.")
      end
    end
  end
end
