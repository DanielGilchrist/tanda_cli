require "./clock_in_day"
require "./leave_lookup/date"
require "./leave_lookup/id"

module TandaCLI
  module Models
    # What `leave show` was given, which is either a leave request id or a day to look leave up on
    module LeaveLookup
      extend self

      alias Any = Date | Id

      def parse(input : String) : Any | Error::Base
        normalised = input.strip

        if id = normalised.to_i32?
          return Id.new(id) if id.positive?
        end

        case day = ClockInDay.parse(normalised)
        in ClockInDay
          Date.new(day)
        in Error::Base
          day
        end
      end
    end
  end
end
