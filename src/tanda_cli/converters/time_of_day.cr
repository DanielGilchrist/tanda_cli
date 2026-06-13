require "../../../kebab/src/kebab"
require "../models/time_of_day"

module TandaCLI
  module Converters
    module TimeOfDay
      def self.parse(input : String) : Models::TimeOfDay | Kebab::Convert::Failure
        case parsed = Models::TimeOfDay.parse(input)
        in Models::TimeOfDay
          parsed
        in ::TandaCLI::Error::Base
          Kebab::Convert.failure(parsed.error_description || parsed.error, name: "time of day")
        end
      end
    end
  end
end
