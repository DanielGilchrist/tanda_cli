module Tanda::CLI
  class CLI::Parser
    class ClockIn < APIParser
      module Options
        struct Frozen
          def initialize(@skip_validations : Bool, @clockin_photo : String?); end

          getter clockin_photo : String?
          getter? skip_validations
        end

        struct Setter
          def self.parse : self
            options = new

            OptionParser.parse do |clockin_options_parser|
              clockin_options_parser.on("--photo=PHOTO", "Specify a clockin photo") do |photo_path|
                options.clockin_photo = photo_path
              end

              clockin_options_parser.on("--skip-validations", "Skip clock in validations") do
                options.skip_validations = true
              end
            end

            options
          end

          def initialize
            @skip_validations = false
            @clockin_photo = nil
          end

          setter skip_validations : Bool
          setter clockin_photo : String?

          def to_frozen : Frozen
            Frozen.new(skip_validations: skip_validations?, clockin_photo: clockin_photo?)
          end

          private getter? skip_validations, clockin_photo
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
        parser.on("photo", "View, set or clear clockin photo to be used by default") do
          parser.on("-s PHOTO", "--set=PHOTO", "Set a clockin photo") do |path|
            if !Models::PhotoParser.valid?(path)
              Utils::Display.error!("Invalid photo path")
            end

            config = Current.config
            config.clockin_photo_path = path
            config.save!

            Utils::Display.success("Clock in photo set to \"#{path}\"")

            exit
          end

          parser.on("view", "View a clockin photo") do
            config = Current.config
            if path = config.clockin_photo_path
              puts "Clock in photo: #{path}"
            else
              puts "No clock in photo set"
            end

            exit
          end

          parser.on("clear", "Clear set clockin photo") do
            config = Current.config
            config.clockin_photo_path = nil
            config.save!

            Utils::Display.success("Clock in photo cleared")

            exit
          end
        end

        parser.on("status", "Check clockin status") do
          CLI::Commands::ClockIn::Status.new(client).execute
        end

        parser.on("display", "Display current clockins") do
          CLI::Commands::ClockIn::Display.new(client).execute
        end

        parser.on("start", "Clock in") do
          execute_clock_in(ClockType::Start)
        end

        parser.on("finish", "Clock out") do
          execute_clock_in(ClockType::Finish)
        end

        parser.on("break", "Clock a break") do
          parser.on("start", "Start break") do
            execute_clock_in(ClockType::BreakStart)
          end

          parser.on("finish", "Finish break") do
            execute_clock_in(ClockType::BreakFinish)
          end
        end
      end

      private def execute_clock_in(type : ClockType)
        options = Options::Setter.parse
        CLI::Commands::ClockIn.new(client, type, options.to_frozen).execute
        exit
      end
    end
  end
end
