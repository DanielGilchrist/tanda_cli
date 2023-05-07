require "json"
require "./schedule"

module Tanda::CLI
  module Types
    class Roster
      class DailySchedule
        include JSON::Serializable

        @[JSON::Field(key: "date")]
        getter date : Time

        getter schedules : Array(Types::Roster::Schedule)
      end
    end
  end
end
