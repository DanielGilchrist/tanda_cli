module TandaCLI
  class Configuration
    class AccessToken
      include JSON::Serializable

      def initialize(
        @email : String? = nil,
        @token : String? = nil,
        @token_type : String? = nil,
        @scopes = Array(Scopes::Scope).new,
        @created_at : Int32? = nil
      ); end

      property email : String?
      property token : String?
      property token_type : String?

      @[JSON::Field(key: "scope", converter: TandaCLI::Types::Converters::ScopesConverter)]
      property scopes : Array(Scopes::Scope)

      property created_at : Int32?
    end
  end
end
