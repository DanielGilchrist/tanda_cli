require "./base"

module Kebab
  module Error
    class MissingOption < Error::Base
      def initialize(name : String)
        super("Missing option!", "\"#{name}\" is required.")
      end
    end
  end
end
