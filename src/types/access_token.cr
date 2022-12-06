require "json"

module Tanda::CLI
  module Types
    class AccessToken
      include JSON::Serializable

      @[JSON::Field(key: "access_token")]
      getter token : String

      getter token_type : String
      getter scope : String
      getter created_at : Int32
    end
  end
end
