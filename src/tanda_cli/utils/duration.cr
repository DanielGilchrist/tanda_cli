module TandaCLI
  module Utils
    module Duration
      extend self

      ZERO         = "0h"
      UNDER_MINUTE = "<1m"

      def compact(span : ::Time::Span) : String
        return ZERO if span.zero?

        magnitude = span.abs
        sign = span.negative? ? "-" : ""
        hours = magnitude.total_hours.to_i
        minutes = magnitude.minutes

        return "#{sign}#{UNDER_MINUTE}" if hours.zero? && minutes.zero?
        return "#{sign}#{minutes}m" if hours.zero?
        return "#{sign}#{hours}h" if minutes.zero?

        "#{sign}#{hours}h #{minutes}m"
      end
    end
  end
end
