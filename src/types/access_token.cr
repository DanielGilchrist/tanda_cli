require "./base"

module Tanda::CLI
  module Types
    class AccessToken < Base
      @[JSON::Field(key: "access_token")]
      getter token : String

      @[JSON::Field(key: "token_type")]
      getter token_type : String

      @[JSON::Field(key: "scope")]
      getter scope : String

      @[JSON::Field(key: "created_at")]
      getter created_at : Int32
    end
  end
end
