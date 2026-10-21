require "./base"

module TandaCLI
  module Error
    class InvalidShiftChoice < Error::Base
      def initialize(input : String, count : Int32) : Nil
        super("Invalid shift!", "\"#{input}\" isn't a number from 1 to #{count}.")
      end
    end
  end
end
