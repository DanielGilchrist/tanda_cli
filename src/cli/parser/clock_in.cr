module Tanda::CLI
  class CLI::Parser
    class ClockIn
      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end

      def initialize(@parser : OptionParser, @client : API::Client); end

      def parse
        parser.on("status", "Check clockin status") do
          now = Utils::Time.now
          clockins = client.clockins(now)

          if clockins.is_a?(Types::Error)
            Utils::Display.error(clockins)
          else
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
          exit
        end

        parser.on("start", "Clock in") do
          execute(ClockType::Start)
        end

        parser.on("finish", "Clock out") do
          execute(ClockType::Finish)
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute(ClockType::BreakStart)
          end

          parser.on("finish", "Finish break") do
            execute(ClockType::BreakFinish)
          end
        end
      end

      private getter parser : OptionParser
      private getter client : API::Client

      private def execute(type : ClockType)
        CLI::Commands::ClockIn.new(client, type).execute
        exit
      end
    end
  end
end
