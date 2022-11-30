require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class ShiftBreak
      include JSON::Serializable
      include Utils::Mixins::PrettyStartFinish

      @[JSON::Field(key: "id")]
      getter id : Int32

      @[JSON::Field(key: "shift_id")]
      getter shift_id : Int32

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      # length in minutes
      @[JSON::Field(key: "length")]
      getter length : UInt8
    end
  end
end
