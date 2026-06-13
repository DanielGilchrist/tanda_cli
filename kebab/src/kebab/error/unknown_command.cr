require "./base"

module Kebab
  module Error
    class UnknownCommand < Error::Base
      def initialize(value : String, candidates : Array(String))
        super("Unknown command!", "\"#{value}\" isn't a known command (expected one of: #{candidates.join(", ")}).")
      end
    end
  end
end
