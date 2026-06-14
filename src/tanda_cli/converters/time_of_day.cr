require "kebab"
require "../models/time_of_day"

module TandaCLI
  module Converters
    module TimeOfDay
      def self.parse(input : String) : Models::TimeOfDay | Kebab::Convert::Failure
        case parsed = Models::TimeOfDay.parse(input)
        in Models::TimeOfDay
          parsed
        in ::TandaCLI::Error::Base
          Kebab::Convert.failure(%(try "8:45", "5:30pm" or "17:30"), name: "time of day")
        end
      end
    end
  end
end
