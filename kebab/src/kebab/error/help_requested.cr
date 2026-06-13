require "./base"

module Kebab
  module Error
    class HelpRequested < Error::Base
      def initialize(@help : String)
        super("Help")
      end

      getter help : String
    end
  end
end
