require "json"

module Tanda::CLI
  module Types
    class AccessToken
      include JSON::Serializable

      @[JSON::Field(key: "access_token")]
      property token : String

      @[JSON::Field(key: "token_type")]
      property token_type : String

      @[JSON::Field(key: "scope")]
      property scope : String

      @[JSON::Field(key: "created_at")]
      property created_at : Int32
    end
  end
end
