module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Status
        def initialize(@client : API::Client); end

        def execute
          now = Utils::Time.now
          client.clockins(now).match do
            ok do |clockins|
              clockin = clockins.sort_by(&.time).last?
              if clockin.nil?
                puts "You aren't currently clocked in"
              else
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
            end

            error(&.display)
          end
        end

        private getter client
      end
    end
  end
end
