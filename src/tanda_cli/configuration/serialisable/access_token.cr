module TandaCLI
  class Configuration
    class Serialisable
      class AccessToken
        include JSON::Serializable

        def self.from(email : String, api_token : API::Types::AccessToken) : self
          new(
            email: email,
            token: api_token.token,
            token_type: api_token.token_type,
            scopes: api_token.scopes,
            created_at: api_token.created_at,
          )
        end

        def initialize(
          @email : String,
          @token : String,
          @token_type : String,
          @scopes : String,
          @created_at : Time,
        ); end

        getter email : String
        getter token : String
        getter token_type : String

        @[JSON::Field(key: "scope")]
        getter scopes : String

        @[JSON::Field(converter: TandaCLI::API::Types::Converters::Time::FromUnix)]
        getter created_at : Time
      end
    end
  end
end
