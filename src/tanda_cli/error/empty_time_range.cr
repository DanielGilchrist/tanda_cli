require "./base"

module TandaCLI
  module Error
    class EmptyTimeRange < Error::Base
      def initialize(value : String) : Nil
        super("Unable to parse hours!", "\"#{value}\" starts and finishes at the same time.")
      end
    end
  end
end
