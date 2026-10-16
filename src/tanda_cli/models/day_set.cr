require "../error/unparseable_day_set"
require "./clock_in_day"

module TandaCLI
  module Models
    struct DaySet
      WEEKDAYS = [
        Time::DayOfWeek::Monday,
        Time::DayOfWeek::Tuesday,
        Time::DayOfWeek::Wednesday,
        Time::DayOfWeek::Thursday,
        Time::DayOfWeek::Friday,
      ]

      WEEKEND = [Time::DayOfWeek::Saturday, Time::DayOfWeek::Sunday]

      ALIASES = {
        "weekdays" => WEEKDAYS,
        "weekend"  => WEEKEND,
        "all"      => WEEKDAYS + WEEKEND,
      }

      def self.parse(input : String) : DaySet | Error::Base
        days = Array(Time::DayOfWeek).new

        input.strip.downcase.split(',').each do |item|
          expanded = expand(item)
          return Error::UnparseableDaySet.new(input) if expanded.nil?

          days.concat(expanded)
        end
        return Error::UnparseableDaySet.new(input) if days.empty?

        new(days.uniq!)
      end

      private def self.expand(item : String) : Array(Time::DayOfWeek)?
        ALIASES[item]? || expand_range(item) || single_day(item)
      end

      private def self.single_day(item : String) : Array(Time::DayOfWeek)?
        day = ClockInDay.parse_day_of_week(item)
        [day] if day
      end

      private def self.expand_range(item : String) : Array(Time::DayOfWeek)?
        first_name, _, last_name = item.partition('-')
        return if last_name.empty?

        first = ClockInDay.parse_day_of_week(first_name)
        last = ClockInDay.parse_day_of_week(last_name)
        return if first.nil? || last.nil?

        days = [first]
        until days.last == last
          days << next_day(days.last)
        end
        days
      end

      private def self.next_day(day : Time::DayOfWeek) : Time::DayOfWeek
        Time::DayOfWeek.from_value(day.value % 7 + 1)
      end

      def initialize(@days : Array(Time::DayOfWeek)) : Nil; end

      getter days : Array(Time::DayOfWeek)

      def one? : Bool
        @days.one?
      end

      def to_s(io : IO) : Nil
        io << @days.join(", ")
      end
    end
  end
end
