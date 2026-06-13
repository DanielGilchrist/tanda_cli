require "./base"

module Kebab
  module Error
    class MissingValue < Error::Base
      def initialize(name : String)
        super("Missing value!", "\"#{name}\" expects a value.")
      end
    end
  end
end
