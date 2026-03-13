require "json"
require "./roster/daily_schedule"

module TandaCLI
  module Types
    struct Roster
      include JSON::Serializable

      @daily_schedules : Array(Roster::DailySchedule) = Array(Roster::DailySchedule).new

      @[JSON::Field(key: "schedules")]
      getter daily_schedules : Array(Roster::DailySchedule)
    end
  end
end
