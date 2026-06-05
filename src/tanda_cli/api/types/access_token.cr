require "json"
require "./converters/time"

module TandaCLI
  module API
    module Types
      struct AccessToken
        include JSON::Serializable

        @[JSON::Field(key: "access_token")]
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
