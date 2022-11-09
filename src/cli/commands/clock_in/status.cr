module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Status
        def initialize(@client : API::Client); end

        def execute
          now = Utils::Time.now
          clockins = client.clockins(now).or(&.display!)
          clockin = clockins.sort_by(&.time).last?
          return puts "You aren't currently clocked in" if clockin.nil?

          case clockin.type
          in Types::ClockIn::Type::Start
            puts "You clocked in at #{clockin.time}"
          in Types::ClockIn::Type::Finish
            puts "You clocked out at #{clockin.time}"
          in Types::ClockIn::Type::BreakStart
            puts "You started a break at #{clockin.time}"
          in Types::ClockIn::Type::BreakFinish
            puts "You finished your break at #{clockin.time}"
          end
        end

        private getter client
      end
    end
  end
end
