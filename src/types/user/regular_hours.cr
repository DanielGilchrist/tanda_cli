require "../converters/time"

module Tanda::CLI
  module Types
    class User
      @[JSON::Serializable::Options(emit_nulls: true)]
      class RegularHours
        include JSON::Serializable

        TIME_STRING_FORMAT = "%H:%M"

        class Schedule
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          class Break
            include Utils::Mixins::PrettyTimes

            def initialize(@start_time : String, @finish_time : String); end

            getter start_time, finish_time

            def start_time : Time
              Time.parse(@start_time, TIME_STRING_FORMAT, Current.time_zone)
            end

            def finish_time : Time
              Time.parse(@finish_time, TIME_STRING_FORMAT, Current.time_zone)
            end

            def length : Time::Span
              finish_time - start_time
            end
          end

          module BreaksConverter
            def self.from_json(value : JSON::PullParser) : Array(Break)
              status_string = value.read_string
              return [] of Break if status_string.presence.nil?

              status_string.split(",").map do |break_string|
                start, finish = break_string.split("-")

                Break.new(start_time: start, finish_time: finish)
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

          @[JSON::Field(key: "start")]
          getter _start : String

          @[JSON::Field(key: "end")]
          getter _finish : String

          @[JSON::Field(converter: Tanda::CLI::Types::User::RegularHours::Schedule::BreaksConverter)]
          getter breaks : Array(Break)

          def start_time : Time
            ::Time.parse(_start, TIME_STRING_FORMAT, Current.time_zone)
          end

          def finish_time : Time
            ::Time.parse(_finish, TIME_STRING_FORMAT, Current.time_zone)
          end
        end

        @[JSON::Field(key: "schedules")]
        private getter _schedules : Array(Schedule)?

        def schedules : Array(Schedule)
          _schedules || Array(Schedule).new
        end

        def blank? : Bool
          schedules = _schedules
          schedules.nil? || schedules.empty?
        end
      end
    end
  end
end
