require "../../client_builder"

module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Display < CLI::Commands::Base
        include CLI::ClientBuilder

        def on_setup
          @name = "display"
          @summary = @description = "Display current clockins"
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          now = Utils::Time.now
          clockins = client.clockins(now).or(&.display!).sort_by(&.time)
          return puts "You aren't currently clocked in" if clockins.empty?

          puts "Clock ins for today"
          clockins.each do |clockin|
            Representers::ClockIn.new(clockin).display
          end
        end
      end
    end
  end
end
