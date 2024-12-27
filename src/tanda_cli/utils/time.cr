module TandaCLI
  module Utils
    module Time
      extend self

      DEFAULT_DATE_FORMAT      = "%A, %d %b %Y"
      DEFAULT_TIME_FORMAT      = "%l:%M %p"
      DEFAULT_DATE_TIME_FORMAT = "#{DEFAULT_DATE_FORMAT} | #{DEFAULT_TIME_FORMAT}"
      ISO_DATE                 = "%Y-%m-%d"

      def now : ::Time
        ::Time.local
      end

      def pretty_date(date : ::Time) : String
        ::Time::Format.new(DEFAULT_DATE_FORMAT).format(date)
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
