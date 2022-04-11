require "json"

module Tanda::CLI
  class Types::ShiftBreak
    include JSON::Serializable

    # TODO: Refactor out
    module TimeConverter
      def self.from_json(value : JSON::PullParser) : Time
        time = Time.unix(value.read_int)
        time.in(Time::Location.load("Europe/London")) # TODO: Don't hard-code time zone
      end
    end

    @[JSON::Field(key: "id")]
    property id : Int32

    @[JSON::Field(key: "shift_id")]
    property shift_id : Int32

    @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property start : Time

    @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Shift::TimeConverter)]
    property finish : Time

    # length in minutes
    @[JSON::Field(key: "length")]
    property length : UInt8
  end
end
