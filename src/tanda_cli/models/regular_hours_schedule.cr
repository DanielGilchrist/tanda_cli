require "../error/break_outside_shift"
require "../error/overlapping_breaks"
require "../error/break_longer_than_shift"
require "./break_plan"
require "./time_range"

module TandaCLI
  module Models
    struct RegularHoursSchedule
      include JSON::Serializable
      include Utils::Mixins::PrettyTimes

      OVERNIGHT_WARNING_LENGTH = 16.hours

      module TimeOfDayConverter
        FORMAT = "%H:%M"

        def self.from_json(value : JSON::PullParser) : Time
          Time.parse(value.read_string, FORMAT, Utils::Time.location)
        end

        def self.to_json(value : Time, json_builder : JSON::Builder) : Nil
          json_builder.string(value.to_s(FORMAT))
        end
      end

      module DayOfWeekConverter
        def self.from_json(value : JSON::PullParser) : Time::DayOfWeek
          day_string = value.read_string
          Time::DayOfWeek.parse?(day_string) || raise("Invalid day of week: #{day_string}")
        end

        def self.to_json(value : Time::DayOfWeek, json_builder : JSON::Builder) : Nil
          json_builder.string(value.to_s)
        end
      end

      def self.build(
        day_of_week : Time::DayOfWeek,
        hours : TimeRange,
        break_plan : BreakPlan::Any,
      ) : self | Error::Base
        start_time = hours.start.to_storage_time
        finish_time = hours.finish.to_storage_time

        case break_plan
        in BreakPlan::Automatic
          if break_plan.length >= hours.length
            return Error::BreakLongerThanShift.new(day_of_week, break_plan.length, hours)
          end

          new(day_of_week, start_time, finish_time, automatic_break_length: break_plan.length)
        in BreakPlan::Fixed
          case breaks = build_breaks(day_of_week, hours, break_plan)
          in Array(Break)
            new(day_of_week, start_time, finish_time, breaks: breaks)
          in Error::Base
            breaks
          end
        in BreakPlan::None
          new(day_of_week, start_time, finish_time)
        end
      end

      private def self.build_breaks(
        day_of_week : Time::DayOfWeek,
        hours : TimeRange,
        break_plan : BreakPlan::Fixed,
      ) : Array(Break) | Error::Base
        ranges = break_plan.ranges.sort_by { |range| hours.offset_of(range.start) }

        ranges.each_cons_pair do |previous, range|
          if hours.offset_of(range.start) < hours.offset_of(previous.finish)
            return Error::OverlappingBreaks.new(day_of_week, previous, range)
          end
        end

        ranges.map do |range|
          unless hours.covers?(range)
            return Error::BreakOutsideShift.new(day_of_week, range, hours)
          end

          Break.new(range.start.to_storage_time, range.finish.to_storage_time)
        end
      end

      def initialize(
        @day_of_week : Time::DayOfWeek,
        @start_time : Time,
        @finish_time : Time,
        @breaks : Array(Break) = Array(Break).new,
        @automatic_break_length : Time::Span = Time::Span.zero,
      ) : Nil; end

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::DayOfWeekConverter)]
      getter day_of_week : Time::DayOfWeek

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
      getter start_time : Time

      @[JSON::Field(converter: TandaCLI::Models::RegularHoursSchedule::TimeOfDayConverter)]
      getter finish_time : Time

      getter breaks : Array(Break)

      @[JSON::Field(converter: TandaCLI::API::Types::Converters::Span::FromMinutes)]
      getter automatic_break_length : Time::Span

      def hours : TimeRange
        TimeRange.new(TimeOfDay.from(start_time), TimeOfDay.from(finish_time))
      end

      def break_plan : BreakPlan::Any
        if (breaks = self.breaks).present?
          BreakPlan::Fixed.new(breaks.map(&.time_range))
        elsif automatic_break_length.positive?
          BreakPlan::Automatic.new(automatic_break_length)
        else
          BreakPlan::None.new
        end
      end

      def with_hours(hours : TimeRange) : self | Error::Base
        self.class.build(day_of_week, hours, break_plan)
      end

      def with_break_plan(break_plan : BreakPlan::Any) : self | Error::Base
        self.class.build(day_of_week, hours, break_plan)
      end

      def same_as?(other : RegularHoursSchedule) : Bool
        day_of_week == other.day_of_week &&
          hours == other.hours &&
          break_plan == other.break_plan
      end

      def pretty_worked : String
        worked = worked_length
        "#{worked.total_hours.to_i}h #{worked.minutes.to_s.rjust(2, '0')}m"
      end

      def length : Time::Span
        Utils::Time.span_between(start_time, finish_time)
      end

      def worked_length : Time::Span
        length - break_length
      end

      def break_length : Time::Span
        if (breaks = self.breaks).present?
          breaks.sum(&.length)
        else
          automatic_break_length
        end
      end
    end
  end
end
