require "./base"

module TandaCLI
  module Error
    class FutureClockIn < Error::Base
      def initialize(time : ::Time)
        super("Clock in time is in the future!", "#{Utils::Time.pretty_date_time(time)} hasn't happened yet.")
      end
    end
  end
end
