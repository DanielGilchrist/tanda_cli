require "json"

require "./converters/time"

module Tanda::CLI
  class Types::ShiftBreak
    include JSON::Serializable

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "shift_id")]
    property shift_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time)]
    property start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time)]
    property finish : Time?

    # length in minutes
    @[JSON::Field(key: "length")]
    property length : UInt8
  end
end
