require "kebab"
require "../models/clock_in_day"

module TandaCLI
  module Converters
    module Day
      extend self

      def convert(input : String) : Models::ClockInDay | Kebab::Convert::Failure
        case parsed = Models::ClockInDay.parse(input)
        in Models::ClockInDay
          parsed
        in ::TandaCLI::Error::Base
          Kebab::Convert.failure(parsed.error_description || parsed.error, name: "day")
        end
      end
    end
  end
end
