require "./base"
require "./converters/time"

module Tanda::CLI
  module Types
    class ClockIn < Base
      enum Type
        Start
        Finish
        BreakStart
        BreakFinish
      end

      module TypeConverter
        def self.from_json(value : JSON::PullParser) : Type
          type_string = value.read_string
          Type.parse?(type_string) || raise "Unknown type: #{type_string}"
        end
      end

      @[JSON::Field(key: "id")]
      getter id : Int32

      @[JSON::Field(key: "type", converter: Tanda::CLI::Types::ClockIn::TypeConverter)]
      getter type : Type

      @[JSON::Field(key: "time", converter: Tanda::CLI::Types::Converters::Time::FromUnix)]
      getter time : Time
    end
  end
end
