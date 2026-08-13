require "../error/unparseable_time_of_day"

module TandaCLI
  module Models
    struct TimeOfDay
      PATTERN = /\A(?<hour>\d{1,2}):?(?<minute>[0-5]\d)?\s*(?<meridiem>[ap](?:\.?m)?\.?)?\z/i

      enum Meridiem
        AM
        PM

        def self.parse?(match : Regex::MatchData) : self?
          meridiem_str = match["meridiem"]?.try(&.downcase.delete('.'))
          return if meridiem_str.nil? || meridiem_str.blank?

          meridiem_str += 'm' if meridiem_str[-1] != 'm'
          Meridiem.parse?(meridiem_str)
        end
      end

      def self.parse(input : String) : TimeOfDay | Error::Base
        match = PATTERN.match(input.strip)
        return unparseable(input) if match.nil?

        hour = match["hour"].to_i
        minute = match["minute"]?.try(&.to_i) || 0
        meridiem = Meridiem.parse?(match)

        case meridiem
        in Meridiem
          return unparseable(input) unless hour.in?(1..12)

          hour = 0 if hour == 12
          hour += 12 if meridiem.is_a?(Meridiem::PM)
        in Nil
          return unparseable(input) unless hour.in?(0..23)
        end

        new(hour, minute)
      end

      private def self.unparseable(input : String) : Error::UnparseableTimeOfDay
        Error::UnparseableTimeOfDay.new(input)
      end

      private def initialize(@hour : Int32, @minute : Int32); end

      getter hour : Int32
      getter minute : Int32

      def on(day : ::Time) : ::Time
        ::Time.local(day.year, day.month, day.day, hour, minute, location: Utils::Time.location)
      end
    end
  end
end
