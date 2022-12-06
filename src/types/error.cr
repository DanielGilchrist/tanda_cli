require "json"

module Tanda::CLI
  module Types
    class Error
      include JSON::Serializable

      @error_description : String? = nil

      getter error : String
      getter error_description : String?

      def display
        Utils::Display.error(self)
      end

      def display! : NoReturn
        Utils::Display.error!(self)
      end
    end
  end
end
