require "../converters/time"

module Tanda::CLI
  module Types
    class User
      @[JSON::Serializable::Options(emit_nulls: true)]
      class RegularHours
        include JSON::Serializable

        class Schedule
          include JSON::Serializable

          class Break
            def initialize(@start : Time, @finish : Time); end
          end

          module BreaksConverter
            def self.from_json(value : JSON::PullParser) : Array(Break)
              status_string = value.read_string
              return [] of Break if status_string.presence.nil?

              status_string.split(",").map do |break_string|
                start, finish = break_string.split("-")
                time_zone = Current.user.time_zone

                Break.new(
                  start: Time.parse(start, "%H:%M", time_zone),
                  finish: Time.parse(finish, "%H:%M", time_zone)
                )
              end
            end
          end

          module DayConverter
            def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
              day_string = value.read_string
              Time::DayOfWeek.parse?(day_string) || Utils::Display.fatal!("Invalid day of week: #{day_string}")
            end
          end

          @[JSON::Field(converter: Tanda::CLI::Types::User::RegularHours::Schedule::DayConverter)]
          getter day : Time::DayOfWeek

          @[JSON::Field(converter: Tanda::CLI::Types::Converters::Time::FromTimeString)]
          getter start : Time

          @[JSON::Field(key: "end", converter: Tanda::CLI::Types::Converters::Time::FromTimeString)]
          getter finish : Time

          @[JSON::Field(converter: Tanda::CLI::Types::User::RegularHours::Schedule::BreaksConverter)]
          getter breaks : Array(Break)
        end

        private getter _schedules : Array(Schedule)?

        def schedules : Array(Schedule)
          _schedules || Array(Schedule).new
        end
      end
    end
  end
end
