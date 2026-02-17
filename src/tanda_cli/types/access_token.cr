require "json"

module TandaCLI
  module Types
    class AccessToken
      include JSON::Serializable

      @[JSON::Field(key: "access_token")]
      getter token : String

      getter token_type : String

      @[JSON::Field(key: "scope")]
      property scopes : String

      getter created_at : Int32
    end
  end
end
