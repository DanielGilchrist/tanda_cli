require "json"

require "./converters/time"

module Tanda::CLI
  class Types::ShiftBreak
    include JSON::Serializable

    @[JSON::Field(key: "id")]
    getter id : Int32

    @[JSON::Field(key: "shift_id")]
    getter shift_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time)]
    getter start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time)]
    getter finish : Time?

    # length in minutes
    @[JSON::Field(key: "length")]
    getter length : UInt8
  end
end
