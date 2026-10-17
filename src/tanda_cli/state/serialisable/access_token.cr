module TandaCLI
  class State
    class Serialisable
      class AccessToken
        include JSON::Serializable

        REDACTED_TOKEN = "[redacted]"

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
        ) : Nil; end

        getter email : String
        getter token : String
        getter token_type : String

        @[JSON::Field(key: "scope")]
        getter scopes : String

        @[JSON::Field(converter: TandaCLI::API::Types::Converters::Time::FromUnix)]
        getter created_at : Time

        def redacted : AccessToken
          AccessToken.new(
            email: @email,
            token: REDACTED_TOKEN,
            token_type: @token_type,
            scopes: @scopes,
            created_at: @created_at,
          )
        end
      end
    end
  end
end
