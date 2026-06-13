require "../../../kebab/src/kebab"
require "../models/clock_in_moment"

module TandaCLI
  module Converters
    module Day
      def self.parse(input : String) : ::Time | Kebab::Error::Base
        Converters.bridge(Models::ClockInMoment.parse_day(input))
      end
    end
  end
end
