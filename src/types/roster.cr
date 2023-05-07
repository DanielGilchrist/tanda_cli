require "json"
require "./roster/daily_schedule"

module Tanda::CLI
  module Types
    class Roster
      include JSON::Serializable

      @[JSON::Field(key: "schedules")]
      getter daily_schedules : Array(Roster::DailySchedule)
    end
  end
end
