module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Status
        def initialize(@client : API::Client); end

        # TODO: Fix lazy logic
        # The logic here should match the status logic in ClockInValidator in src/cli/commands/clock_in.cr
        # to handle the case where clock ins aren't in a sound order
        def execute
          now = Utils::Time.now
          clockins = client.clockins(now).or(&.display!)
          clockin = clockins.sort_by(&.time).last?
          return puts "You aren't currently clocked in" if clockin.nil?

          case clockin.type
          in Types::ClockIn::Type::Start
            display_clocked_in
            puts "You clocked in at #{clockin.pretty_date_time}"
          in Types::ClockIn::Type::Finish
            display_clocked_out
            puts "You clocked out at #{clockin.pretty_date_time}"
          in Types::ClockIn::Type::BreakStart
            display_on_break
            puts "You started a break at #{clockin.pretty_date_time}"
          in Types::ClockIn::Type::BreakFinish
            display_clocked_in
            puts "You finished your break at #{clockin.pretty_date_time}"
          end
        end

        private getter client

        private def display_clocked_in
          puts "You are clocked in"
        end

        private def display_clocked_out
          puts "You are clocked out"
        end

        private def display_on_break
          puts "You are on break"
        end
      end
    end
  end
end
