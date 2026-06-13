require "./base"

module Kebab
  module Error
    class Unparsable < Error::Base
      def initialize(expected : String)
        super("Unparsable value!", "expected #{expected}")
      end
    end
  end
end
