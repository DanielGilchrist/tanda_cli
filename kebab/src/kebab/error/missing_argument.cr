require "./base"

module Kebab
  module Error
    class MissingArgument < Error::Base
      def initialize(@argument : String)
        super("Missing argument!", "\"#{@argument}\" is required.")
      end

      getter argument : String
    end
  end
end
