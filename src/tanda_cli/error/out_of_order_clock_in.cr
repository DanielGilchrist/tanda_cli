require "./base"

module TandaCLI
  module Error
    class OutOfOrderClockIn < Error::Base
      def initialize(time : ::Time, previous : ::Time) : Nil
        super("Clock in time is out of order!", "#{Utils::Time.pretty_time(time)} must be after #{Utils::Time.pretty_time(previous)}.")
      end
    end
  end
end
