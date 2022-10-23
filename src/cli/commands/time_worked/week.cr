require "./base"

module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      class Week < Base
        def initialize(client : API::Client, list : Bool)
          @client = client
          @list = list
        end

        def execute
          now = Time.local
          shifts = client.shifts(now.at_beginning_of_week, now)
          total_time_worked = calculate_time_worked(shifts, print: list?)

          if total_time_worked.zero?
            puts "You haven't clocked in this week"
          else
            puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
          end
        end

        private getter list : Bool
        private def list?
          list
        end
      end
    end
  end
end
