require "../error/future_date"
require "../error/unparseable_date"

module TandaCLI
  module Models
    # A day given on the command line, which can only become a date once the configured start of the week is known
    struct ClockInDay
      SHORTEST_DAY_NAME = 3

      def self.parse(input : String) : ClockInDay | Error::Base
        normalised = input.strip.downcase

        case normalised
        when "today"
          new(Utils::Time.now)
        when "yesterday"
          new(Utils::Time.now - 1.day)
        else
          day_of_week = parse_day_of_week(normalised)
          return new(day_of_week) if day_of_week

          begin
            new(Utils::Time.iso_date(normalised))
          rescue ::Time::Format::Error
            Error::UnparseableDate.new(input)
          end
        end
      end

      def self.parse_day_of_week(input : String) : ::Time::DayOfWeek?
        return if input.size < SHORTEST_DAY_NAME

        matches = ::Time::DayOfWeek.values.select(&.to_s.downcase.starts_with?(input))
        matches.first if matches.one?
      end

      private def initialize(@day : ::Time | ::Time::DayOfWeek) : Nil; end

      def on(start_of_week : ::Time::DayOfWeek) : ::Time
        day = @day
        return day if day.is_a?(::Time)

        Utils::Time.now.at_beginning_of_week(start_of_week) + days_into_week(day, start_of_week)
      end

      def on_or_before_today(start_of_week : ::Time::DayOfWeek) : ::Time | Error::FutureDate
        day = on(start_of_week)
        return Error::FutureDate.new(day) if day.date > Utils::Time.now.date

        day
      end

      private def days_into_week(day : ::Time::DayOfWeek, start_of_week : ::Time::DayOfWeek) : ::Time::Span
        ((day.value - start_of_week.value) % 7).days
      end
    end
  end
end
