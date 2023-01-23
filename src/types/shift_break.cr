require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class ShiftBreak
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      getter id : Int32
      getter shift_id : Int32
      getter length : UInt16 # length in minutes

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?
    end
  end
end
