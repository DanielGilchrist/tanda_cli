module Tanda::CLI
  class CLI::Parser
    class ClockIn < APIParser
      def parse
        @parser.on("photo", "View, set or clear clockin photo to be used by default") do
          @parser.on("-s PHOTO", "--set=PHOTO", "Set a clockin photo") do |path|
            if !Models::PhotoPathParser.valid?(path)
              Utils::Display.error!("Invalid photo path")
            end

            config = Current.config
            config.clockin_photo_path = path
            config.save!

            Utils::Display.success("Clock in photo set to \"#{path}\"")

            exit
          end

          @parser.on("view", "View a clockin photo") do
            config = Current.config
            if path = config.clockin_photo_path
              puts "Clock in photo: #{path}"
            else
              puts "No clock in photo set"
            end

            exit
          end

          @parser.on("clear", "Clear set clockin photo") do
            config = Current.config
            config.clockin_photo_path = nil
            config.save!

            Utils::Display.success("Clock in photo cleared")

            exit
          end
        end

        @parser.on("status", "Check clockin status") do
          CLI::Executors::ClockIn::Status.new(client).execute
        end

        @parser.on("display", "Display current clockins") do
          CLI::Executors::ClockIn::Display.new(client).execute
        end
      end
    end
  end
end
