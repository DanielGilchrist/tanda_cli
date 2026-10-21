require "./base"

module TandaCLI
  module Error
    class LeaveWindowTooLong < Error::Base
      def initialize(days : Int32, maximum : Int32) : Nil
        super(
          "That's too long a period to look up leave for!",
          "#{days} days were asked for and the API only allows #{maximum} at a time"
        )
      end
    end
  end
end
