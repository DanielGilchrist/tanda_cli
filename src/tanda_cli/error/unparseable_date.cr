require "./base"

module TandaCLI
  module Error
    class UnparseableDate < Error::Base
      def initialize(value : String) : Nil
        super("\"#{value}\" doesn't look like a date", "Try a day name like \"wednesday\" or \"wed\", \"today\", \"tomorrow\", \"yesterday\" or YYYY-MM-DD")
      end
    end
  end
end
