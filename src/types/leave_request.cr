require "json"

require "./converters/time"

module Tanda::CLI
  class Types::ShiftBreak
    include JSON::Serializable

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time)]
    property start : Time?

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time)]
    property finish : Time?
  end
end
