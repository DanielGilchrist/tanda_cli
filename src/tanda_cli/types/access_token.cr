require "json"

module TandaCLI
  module Types
    class AccessToken
      include JSON::Serializable

      @[JSON::Field(key: "access_token")]
      getter token : String

      getter token_type : String

      @[JSON::Field(key: "scope", converter: TandaCLI::Types::Converters::ScopeConverter)]
      property scopes : Array(Scopes::Scope)

      getter created_at : Int32
    end
  end
end
