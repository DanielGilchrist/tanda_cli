require "json"

module TandaCLI
  module Types
    class Note
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      getter author : String
      getter body : String

      @[JSON::Field(key: "updated_at", converter: TandaCLI::Types::Converters::Time::FromUnix)]
      getter time : Time
    end
  end
end
