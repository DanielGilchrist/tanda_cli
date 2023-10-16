require "../../utils/mixins/pretty_times"

module TandaCLI
  class Configuration
    class Organisation
      include JSON::Serializable

      TIME_STRING_FORMAT = "%H:%M"

      def self.from(organisation : Types::Me::Organisation) : self
        new(
          organisation.id,
          organisation.name,
          organisation.user_id
        )
      end

      def self.from(me : Types::Me) : Array(self)
        me.organisations.map(&->from(Types::Me::Organisation))
      end

      def initialize(
        @id : Int32,
        @name : String,
        @user_id : Int32,
        @current : Bool = false,
        @regular_hours_schedules : Array(RegularHoursSchedule)? = nil
      ); end

      getter id : Int32
      getter name : String
      getter user_id : Int32
      property? current : Bool

      @[JSON::Field(key: "regular_hours")]
      getter regular_hours_schedules : Array(RegularHoursSchedule)?

      def set_regular_hours!(schedules_with_day_of_week : Array({day_of_week: Time::DayOfWeek, schedule: Types::Schedule}))
        @regular_hours_schedules = schedules_with_day_of_week.compact_map do |schedule_with_day_of_week|
          schedule = schedule_with_day_of_week[:schedule]
          day_of_week = schedule_with_day_of_week[:day_of_week]

          schedule_start_time = schedule.start_time
          schedule_finish_time = schedule.finish_time
          next if schedule_start_time.nil? || schedule_finish_time.nil?

          breaks = begin
            if (schedule_breaks = schedule.breaks).empty?
              Array(RegularHoursSchedule::Break).new
            else
              schedule_breaks.compact_map do |schedule_break|
                start_time = schedule_break.start_time
                finish_time = schedule_break.finish_time
                next if start_time.nil? || finish_time.nil?

                RegularHoursSchedule::Break.new(
                  start_time.to_s(TIME_STRING_FORMAT),
                  finish_time.to_s(TIME_STRING_FORMAT)
                )
              end
            end
          end

          RegularHoursSchedule.new(
            day_of_week: day_of_week,
            breaks: breaks,
            automatic_break_length: schedule.automatic_break_length,
            start_time: schedule_start_time,
            finish_time: schedule_finish_time
          )
        end
      end

      class RegularHoursSchedule
        include JSON::Serializable
        include Utils::Mixins::PrettyTimes

        module DayConverter
          def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
            day_string = value.read_string
            Time::DayOfWeek.parse?(day_string) || Utils::Display.fatal!("Invalid day of week: #{day_string}")
          end

          def self.to_json(value, json_builder : JSON::Builder)
            json_builder.string(value.to_s)
          end
        end

        class Break
          include JSON::Serializable
          include Utils::Mixins::PrettyTimes

          def initialize(@_start_time : String, @_finish_time : String); end

          def start_time : Time
            Time.parse(@_start_time, TIME_STRING_FORMAT, Current.time_zone)
          end

          def finish_time : Time
            Time.parse(@_finish_time, TIME_STRING_FORMAT, Current.time_zone)
          end

          def length : Time::Span
            finish_time - start_time
          end
        end

        def initialize(
          @day_of_week : Time::DayOfWeek,
          start_time : (String | Time),
          finish_time : (String | Time),
          @breaks : Array(Break) = Array(Break).new,
          @automatic_break_length : UInt16 = 0
        )
          # TODO: I don't believe we should have to `.as(String)` here
          @_start_time = begin
            case start_time
            in String
              start_time
            in Time
              start_time.to_s(TIME_STRING_FORMAT)
            end
          end.as(String)

          # TODO: I don't believe we should have to `.as(String)` here
          @_finish_time = begin
            case finish_time
            in String
              finish_time
            in Time
              finish_time.to_s(TIME_STRING_FORMAT)
            end
          end.as(String)
        end

        @[JSON::Field(converter: TandaCLI::Configuration::Organisation::RegularHoursSchedule::DayConverter)]
        getter day_of_week : Time::DayOfWeek

        getter breaks : Array(Break)

        getter automatic_break_length : UInt16?

        def start_time : Time
          Time.parse(@_start_time, TIME_STRING_FORMAT, Current.time_zone)
        end

        def finish_time : Time
          Time.parse(@_finish_time, TIME_STRING_FORMAT, Current.time_zone)
        end

        def length : Time::Span
          finish_time - start_time
        end

        def break_length : Time::Span
          if !(breaks = self.breaks).empty?
            breaks.sum(&.length)
          else
            (automatic_break_length || 0).minutes
          end
        end
      end
    end
  end
end
