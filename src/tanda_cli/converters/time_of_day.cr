require "../../../kebab/src/kebab"
require "../models/time_of_day"

module TandaCLI
  module Converters
    # Adapts Models::TimeOfDay's tanda-flavoured parse result into the Kebab
    # converter protocol so commands can declare `getter at : Models::TimeOfDay?`
    # and parsing happens at the CLI boundary.
    module TimeOfDay
      def self.parse(input : String) : Models::TimeOfDay | Kebab::Error::Base
        Converters.bridge(Models::TimeOfDay.parse(input))
      end
    end
  end
end
