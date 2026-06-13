require "../../../kebab/src/kebab"
require "../models/clock_in_moment"

module TandaCLI
  module Converters
    # Accepts "today", "yesterday", or YYYY-MM-DD and produces a Time anchored
    # at midnight local of that day. Delegates to ClockInMoment.parse_day so
    # there's one source of truth for the format.
    module Day
      def self.parse(input : String) : ::Time | Kebab::Error::Base
        Converters.bridge(Models::ClockInMoment.parse_day(input))
      end
    end
  end
end
