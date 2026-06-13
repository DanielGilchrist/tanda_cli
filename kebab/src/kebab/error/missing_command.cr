require "./base"

module Kebab
  module Error
    class MissingCommand < Error::Base
      def initialize(candidates : Array(String))
        super("Missing command!", "expected one of: #{candidates.join(", ")}.")
      end
    end
  end
end
