require "./determine_status"

module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Status
        include ClockIn::DetermineStatus

        def initialize(@client : API::Client); end

        def execute
          reversed_clockins = clockins.sort_by(&.time).reverse!

          case determine_status
          in ClockInStatus::ClockedIn
            handle_clocked_in(reversed_clockins)
          in ClockInStatus::ClockedOut
            handle_clocked_out(reversed_clockins)
          in ClockInStatus::BreakStarted
            handle_break_started(reversed_clockins)
          end
        end

        private getter client

        private def handle_clocked_in(clockins : Array(Types::ClockIn))
          puts "You are clocked in"

          if finished_break = clockins.find(&.type.==(Types::ClockIn::Type::BreakFinish))
            puts "You finished your break at #{finished_break.pretty_date_time}"
          else
            if (latest_clockin = clockins.find(&.type.==(Types::ClockIn::Type::Start))).nil?
              Utils::Display.fatal!("Clock in status is clocked in but clock in can't be found!")
            end

            puts "You clocked in at #{latest_clockin.pretty_date_time}"
          end
        end

        private def handle_clocked_out(clockins : Array(Types::ClockIn))
          puts "You are clocked out"

          if latest_clockout = clockins.find(&.type.==(Types::ClockIn::Type::Finish))
            puts "You clocked out at #{latest_clockout.pretty_date_time}"
          else
            puts "You aren't currently clocked in"
          end
        end

        private def handle_break_started(clockins : Array(Types::ClockIn))
          puts "You are on break"

          if (latest_break_start = clockins.find(&.type.==(Types::ClockIn::Type::BreakStart))).nil?
            Utils::Display.fatal!("Clock in status is break start but break start can't be found!")
          end

          puts "You started a break at #{latest_break_start.pretty_date_time}"
        end

        private def clockins : Array(Types::ClockIn)
          client.clockins(Utils::Time.now).or(&.display!)
        end
      end
    end
  end
end
