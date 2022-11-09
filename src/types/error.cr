require "json"

module Tanda::CLI
  module Types
    class Error
      include JSON::Serializable

      @error_description : String? = nil

      @[JSON::Field(key: "error")]
      getter error : String

      @[JSON::Field(key: "error_description")]
      getter error_description : String?

      def display
        Utils::Display.error(self)
      end

      def display! : NoReturn
        Utils::Display.error(self)
        exit
      end
    end
  end
end
