require "../error/unparseable_break"
require "../error/mixed_breaks"
require "./break_plan/*"
require "./time_range"

module TandaCLI
  module Models
    module BreakPlan
      alias Any = Automatic | Fixed | None

      MINUTES = /\A(?<minutes>\d+)\s*(m|min|mins|minutes)\z/i

      def self.parse(specs : Array(String)) : Any | Error::Base
        joined = specs.join(' ').strip.downcase
        return Error::UnparseableBreak.new(joined) if joined.empty?
        return None.new if joined == "none"

        match = MINUTES.match(joined)
        return parse_fixed(specs) if match.nil?

        minutes = match["minutes"].to_i
        return None.new if minutes.zero?

        Automatic.new(minutes.minutes)
      end

      private def self.parse_fixed(specs : Array(String)) : Fixed | Error::Base
        ranges = specs.map do |spec|
          return Error::MixedBreaks.new if MINUTES.matches?(spec)

          case parsed = TimeRange.parse(spec)
          in TimeRange
            parsed
          in Error::Base
            return Error::UnparseableBreak.new(spec)
          end
        end

        Fixed.new(ranges)
      end
    end
  end
end
