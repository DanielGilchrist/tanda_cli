module Tanda::CLI
  class CLI::Parser
    class ClockIn < APIParser
      struct Options
        struct Frozen
          def initialize(@skip_validations : Bool = false, @clockin_photo : Bool = false); end
          getter? skip_validations, clockin_photo
        end

        def self.parse : Options
          options = Options.new

          OptionParser.parse do |clockin_options_parser|
            clockin_options_parser.on("-p", "--with-clockin-photo", "Use a clockin photo") do
              options.clockin_photo = true
            end

            clockin_options_parser.on("--skip-validations", "Skip clock in validations") do
              options.skip_validations = true
            end
          end

          options
        end

        def initialize(@skip_validations : Bool = false, @clockin_photo : Bool = false); end

        property? skip_validations, clockin_photo

        def to_frozen : Frozen
          Frozen.new(skip_validations: skip_validations?, clockin_photo: clockin_photo?)
        end
      end

      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end

      def parse
        parser.on("status", "Check clockin status") do
          CLI::Commands::ClockIn::Status.new(client).execute
        end

        parser.on("display", "Display current clockins") do
          CLI::Commands::ClockIn::Display.new(client).execute
        end

        options = Options.parse

        parser.on("start", "Clock in") do
          execute_clock_in(ClockType::Start, options)
        end

        parser.on("finish", "Clock out") do
          execute_clock_in(ClockType::Finish, options)
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute_clock_in(ClockType::BreakStart, options)
          end

          parser.on("finish", "Finish break") do
            execute_clock_in(ClockType::BreakFinish, options)
          end
        end
      end

      private def execute_clock_in(type : ClockType, options : Options)
        CLI::Commands::ClockIn.new(client, type, options.to_frozen).execute
        exit
      end
    end
  end
end
