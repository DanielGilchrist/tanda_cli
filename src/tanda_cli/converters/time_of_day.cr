require "../../../kebab/src/kebab"
require "../models/time_of_day"

module TandaCLI
  module Converters
    module TimeOfDay
      def self.parse(input : String) : Models::TimeOfDay | Kebab::Error::InvalidValue
        case parsed = Models::TimeOfDay.parse(input)
        in Models::TimeOfDay
          parsed
        in ::TandaCLI::Error::Base
          Kebab.invalid_value(parsed.error_description || parsed.error)
        end
      end
    end
  end
end
