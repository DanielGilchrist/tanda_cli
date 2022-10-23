module Tanda::CLI
  module CLI::Commands
    module TimeWorked
      abstract class Base
        def initialize(client : API::Client)
          @client = client
        end

        private getter client : API::Client

        abstract def execute

        private def calculate_time_worked(shifts : Array(Types::Shift), print : Bool = false) : Time::Span
          total_time_worked = Time::Span.zero
          shifts.each do |shift|
            time_worked = shift.time_worked
            worked_so_far = shift.worked_so_far

            print_shift(shift, time_worked, worked_so_far) if print

            total_time = time_worked || worked_so_far
            total_time_worked += total_time if total_time
          end

          total_time_worked
        end

        private def print_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?)
          time_worked && puts "Time worked: #{time_worked.hours} hours and #{time_worked.minutes} minutes"
          (!time_worked && worked_so_far) && puts "Worked so far: #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"

          Representers::Shift.new(shift).display
        end
      end
    end
  end
end
