require "./base"

module Kebab
  module Error
    class UnknownCommand < Error::Base
      def initialize(@command : String, @candidates : Array(String))
        super("Unknown command!", "\"#{@command}\" isn't a known command (expected one of: #{@candidates.join(", ")}).")
      end

      getter command : String
      getter candidates : Array(String)
    end
  end
end
