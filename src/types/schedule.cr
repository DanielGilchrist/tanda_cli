require "json"
require "./converters/time"

module Tanda::CLI
  module Types
    class Schedule
      include JSON::Serializable

      # class Break
      #   include JSON::Serializable

      #   @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      #   getter start_time : Time?

      #   @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      #   getter finish_time : Time?
      # end

      # {
      #   "id": 31337157,
      #   "roster_id": 70074,
      #   "user_id": 123456,
      #   "start": 1456902000,
      #   "finish": 1456916400,
      #   "breaks": [
      #     {
      #       "start": 1456909200,
      #       "finish": 1456911000
      #     }
      #   ],
      #   "automatic_break_length": 30,
      #   "department_id": 111,
      #   "shift_detail_id": 36,
      #   "cost": 20.19,
      #   "last_published_at": 1457002800,
      #   "acceptance_status: `not_accepted`": "Hello, world!",
      #   "record_id": 532432,
      #   "needs_acceptance": true
      # }

      @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter start_time : Time?

      @[JSON::Field(key: "finish", converter: Tanda::CLI::Types::Converters::Time::FromMaybeUnix)]
      getter finish_time : Time?

      getter automatic_break_length : UInt16
      # getter breaks : Array(Schedule::Break)
      getter user_id : Int32
    end
  end
end
