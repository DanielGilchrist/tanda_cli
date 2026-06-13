require "./base"

module Kebab
  module Error
    class UnexpectedArgument < Error::Base
      def initialize(@value : String)
        super("Unexpected argument!", "\"#{@value}\" wasn't expected here.")
      end

      getter value : String
    end
  end
end
