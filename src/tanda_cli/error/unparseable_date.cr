require "./base"

module TandaCLI
  module Error
    class UnparseableDate < Error::Base
      def initialize(value : String)
        super("Unable to parse date!", "\"#{value}\" doesn't look like a date (try \"yesterday\" or YYYY-MM-DD).")
      end
    end
  end
end
