require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class Schedule
      include JSON::Serializable

      class Break
        include JSON::Serializable

        @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
        getter start_time : Time?

        @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
        getter finish_time : Time?
      end

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      getter automatic_break_length : UInt16
      getter breaks : Array(Schedule::Break)
      getter user_id : Int32
    end
  end
end
