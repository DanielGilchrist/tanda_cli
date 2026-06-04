require "json"

module TandaCLI
  module API
    module Types
      struct Note
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        getter author : String
        getter body : String

        @[JSON::Field(key: "updated_at", converter: TandaCLI::API::Types::Converters::Time::FromUnix)]
        getter time : Time
      end
    end
  end
end
