require "kebab"
require "../models/clock_in_moment"

module TandaCLI
  module Converters
    module Day
      def self.parse(input : String) : ::Time | Kebab::Convert::Failure
        case parsed = Models::ClockInMoment.parse_day(input)
        in ::Time
          parsed
        in ::TandaCLI::Error::Base
          Kebab::Convert.failure(parsed.error_description || parsed.error, name: "day")
        end
      end
    end
  end
end
