require "./base"

module Kebab
  module Error
    class UnknownOption < Error::Base
      def initialize(@option : String)
        super("Unknown option!", "\"#{@option}\" isn't a recognised option.")
      end

      getter option : String
    end
  end
end
