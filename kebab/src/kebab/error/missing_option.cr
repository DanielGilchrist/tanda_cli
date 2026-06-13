require "./base"

module Kebab
  module Error
    class MissingOption < Error::Base
      def initialize(@option : String)
        super("Missing option!", "\"#{@option}\" is required.")
      end

      getter option : String
    end
  end
end
