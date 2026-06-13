require "../../../kebab/src/kebab"
require "../models/clock_in_moment"

module TandaCLI
  module Converters
    module Day
      def self.parse(input : String) : ::Time | Kebab::Error::Unparseable
        case parsed = Models::ClockInMoment.parse_day(input)
        in ::Time
          parsed
        in ::TandaCLI::Error::Base
          Kebab.parse_error(parsed.error_description || parsed.error)
        end
      end
    end
  end
end
