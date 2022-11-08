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
    end
  end
end
