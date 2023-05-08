require "../converters/time"

module Tanda::CLI
  module Types
    class User
      @[JSON::Serializable::Options(emit_nulls: true)]
      class RegularHours
        include JSON::Serializable

        class Schedule
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          class Break
            include Utils::Mixins::PrettyTimes

            def initialize(@start_time : Time, @finish_time : Time); end

            getter start_time, finish_time

            def length : Time::Span
              finish_time - start_time
            end
          end

          module BreaksConverter
            def self.from_json(value : JSON::PullParser) : Array(Break)
              status_string = value.read_string
              return [] of Break if status_string.presence.nil?

              time_zone = Current.time_zone
              status_string.split(",").map do |break_string|
                start, finish = break_string.split("-")

                Break.new(
                  start_time: Time.parse(start, "%H:%M", time_zone),
                  finish_time: Time.parse(finish, "%H:%M", time_zone)
                )
              end
            end

            def self.to_json(value, json_builder : JSON::Builder)
              json = value.map do |break_|
                "#{break_.start_time.to_s("%H:%M")}-#{break_.finish_time.to_s("%H:%M")}"
              end.join(",")

              json_builder.string(json)
            end
          end

          module DayConverter
            def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
              day_string = value.read_string
              Time::DayOfWeek.parse?(day_string) || Utils::Display.fatal!("Invalid day of week: #{day_string}")
            end

            def self.to_json(value, json_builder : JSON::Builder)
              json_builder.string(value.to_s)
            end
          end

          @[JSON::Field(converter: Tanda::CLI::Types::User::RegularHours::Schedule::DayConverter)]
          getter day : Time::DayOfWeek

          @[JSON::Field(key: "start", converter: Tanda::CLI::Types::Converters::Time::FromTimeString)]
          getter start_time : Time

          @[JSON::Field(key: "end", converter: Tanda::CLI::Types::Converters::Time::FromTimeString)]
          getter finish_time : Time

          @[JSON::Field(converter: Tanda::CLI::Types::User::RegularHours::Schedule::BreaksConverter)]
          getter breaks : Array(Break)
        end

        @[JSON::Field(key: "schedules")]
        private getter _schedules : Array(Schedule)?

        def schedules : Array(Schedule)
          _schedules || Array(Schedule).new
        end
      end
    end
  end
end
