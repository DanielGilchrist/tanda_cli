require "../error/unparseable_time_range"
require "../error/empty_time_range"
require "./time_of_day"

module TandaCLI
  module Models
    struct TimeRange
      PATTERN = /\A(?<start>[^-]+?)\s*-\s*(?<finish>[^-]+)\z/

      def self.parse(input : String) : TimeRange | Error::Base
        match = PATTERN.match(input.strip)
        return Error::UnparseableTimeRange.new(input) if match.nil?

        start = TimeOfDay.parse(match["start"])
        return Error::UnparseableTimeRange.new(input) if start.is_a?(Error::Base)

        finish = TimeOfDay.parse(match["finish"])
        return Error::UnparseableTimeRange.new(input) if finish.is_a?(Error::Base)
        return Error::EmptyTimeRange.new(input) if start == finish

        new(start, finish)
      end

      def initialize(@start : TimeOfDay, @finish : TimeOfDay) : Nil; end

      getter start : TimeOfDay
      getter finish : TimeOfDay

      def length : Time::Span
        offset_of(finish)
      end

      def overnight? : Bool
        finish < start
      end

      def offset_of(time : TimeOfDay) : Time::Span
        ((time.minutes_of_day - start.minutes_of_day) % TimeOfDay::MINUTES_PER_DAY).minutes
      end

      def covers?(other : TimeRange) : Bool
        start_offset = offset_of(other.start)
        finish_offset = offset_of(other.finish)

        start_offset < finish_offset && finish_offset <= length
      end

      def pretty : String
        "#{start.pretty} - #{finish.pretty}"
      end

      def to_s(io : IO) : Nil
        io << start << '-' << finish
      end
    end
  end
end
