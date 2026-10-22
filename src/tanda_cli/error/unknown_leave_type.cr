require "./base"

module TandaCLI
  module Error
    class UnknownLeaveType < Error::Base
      def initialize(value : String, available : Array(String)) : Nil
        super(
          "No leave type matches \"#{value}\"",
          available.empty? ? "You have no leave types available" : "Your types are: #{available.join(", ")}"
        )
      end
    end
  end
end
