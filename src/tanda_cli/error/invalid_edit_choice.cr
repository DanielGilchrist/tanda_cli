require "./base"

module TandaCLI
  module Error
    class InvalidEditChoice < Error::Base
      def initialize(input : String, count : Int32, can_add_break : Bool) : Nil
        options = can_add_break ? "a number from 1 to #{count} or b" : "a number from 1 to #{count}"

        super("Invalid choice!", "\"#{input}\" isn't #{options}.")
      end
    end
  end
end
