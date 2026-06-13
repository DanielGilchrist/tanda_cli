require "./base"

module Kebab
  module Error
    class UnknownOption < Error::Base
      def initialize(name : String)
        super("Unknown option!", "\"#{name}\" isn't a recognised option.")
      end
    end
  end
end
