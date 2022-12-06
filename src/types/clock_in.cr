require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class ClockIn
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      enum Type
        Start
        Finish
        BreakStart
        BreakFinish
      end

      module TypeConverter
        def self.from_json(value : JSON::PullParser) : Type
          type_string = value.read_string
          Type.parse?(type_string) || Utils::Display.fatal!("Unknown type: #{type_string}")
        end
      end

      getter id : Int32

      @[JSON::Field(key: "type", converter: Tanda::CLI::Types::ClockIn::TypeConverter)]
      getter type : Type

      @[JSON::Field(key: "time", converter: Tanda::CLI::Types::Converters::Time::FromUnix)]
      getter time : Time
    end
  end
end
