require "./base"

module TandaCLI
  module Error
    class UnparsableTimeOfDay < Error::Base
      def initialize(value : String)
        super("Unable to parse time!", "\"#{value}\" doesn't look like a time of day (try \"8:45\", \"5:30pm\" or \"17:30\").")
      end
    end
  end
end
