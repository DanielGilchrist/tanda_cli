require "../../../kebab/src/kebab"
require "../models/time_of_day"

module TandaCLI
  module Converters
    module TimeOfDay
      def self.parse(input : String) : Models::TimeOfDay | Kebab::Error::Base
        Converters.bridge(Models::TimeOfDay.parse(input))
      end
    end
  end
end
