require "./base"

module Kebab
  module Error
    class MissingValue < Error::Base
      def initialize(@option : String)
        super("Missing value!", "\"#{@option}\" expects a value.")
      end

      getter option : String
    end
  end
end
