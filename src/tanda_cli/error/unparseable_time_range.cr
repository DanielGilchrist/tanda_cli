require "./base"

module TandaCLI
  module Error
    class UnparseableTimeRange < Error::Base
      def initialize(value : String) : Nil
        super(
          "Unable to parse hours!",
          %("#{value}" doesn't look like a time range (try "8:30-17:00" or "9am-5:30pm").),
        )
      end
    end
  end
end
