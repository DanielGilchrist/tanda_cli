module TandaCLI
  module Utils
    module Time
      extend self

      DEFAULT_DATE_FORMAT      = "%A, %d %b %Y"
      SHORT_DATE_FORMAT        = "%a %d %b"
      SHORT_DAY                = "%a %d %b"
      LONG_DAY                 = "%a %d %b %Y"
      RANGE                    = "–"
      DEFAULT_TIME_FORMAT      = "%l:%M %p"
      DEFAULT_DATE_TIME_FORMAT = "#{DEFAULT_DATE_FORMAT} | #{DEFAULT_TIME_FORMAT}"
      ISO_DATE                 = "%Y-%m-%d"

      def now : ::Time
        ::Time.local
      end

      # Times of day carry no date, so a finish before the start wraps past midnight
      def span_between(start_time : ::Time, finish_time : ::Time) : ::Time::Span
        span = finish_time - start_time
        span.negative? ? span + 1.day : span
      end

      def at_date(date : ::Time, time_of_day : ::Time) : ::Time
        ::Time.local(
          date.year,
          date.month,
          date.day,
          time_of_day.hour,
          time_of_day.minute,
          location: location
        )
      end

      def pretty_date(date : ::Time) : String
        ::Time::Format.new(DEFAULT_DATE_FORMAT).format(date)
      end

      def pretty_short_date(date : ::Time) : String
        format(date, LONG_DAY)
      end

      def short_date(date : ::Time) : String
        ::Time::Format.new(SHORT_DATE_FORMAT).format(date)
      end

      def date_range(start : ::Time, finish : ::Time) : String
        return format(start, LONG_DAY) if start == finish

        if start.year == finish.year
          "#{format(start, SHORT_DAY)} #{RANGE} #{format(finish, LONG_DAY)}"
        else
          "#{format(start, LONG_DAY)} #{RANGE} #{format(finish, LONG_DAY)}"
        end
      end

      private def format(date : ::Time, pattern : String) : String
        ::Time::Format.new(pattern).format(date)
      end

      def pretty_time(time : ::Time) : String
        ::Time::Format.new(DEFAULT_TIME_FORMAT).format(time).lstrip
      end

      def pretty_date_time(time : ::Time) : String
        ::Time::Format.new(DEFAULT_DATE_TIME_FORMAT).format(time).squeeze(' ')
      end

      def iso_date(date : ::Time) : String
        ::Time::Format.new(ISO_DATE).format(date)
      end

      def iso_date(date : String) : ::Time
        ::Time.parse(date, ISO_DATE, location)
      end

      def location : ::Time::Location
        ::Time::Location.local
      end
    end
  end
end
