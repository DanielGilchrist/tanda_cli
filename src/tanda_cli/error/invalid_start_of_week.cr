module TandaCLI
  module Error
    class InvalidStartOfWeek < Error::Base
      def initialize(value : String)
        super("Invalid start of week!", "\"#{value}\" is not a valid day of the week.")
      end
    end
  end
end
