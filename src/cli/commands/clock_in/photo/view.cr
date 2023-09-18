module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Photo
        class View < CLI::Commands::Base
          def on_setup
            @name = "view"
            @summary = @description = "View the currently set clockin photo or directory"
          end

          def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
            config = Current.config

            if path = config.clockin_photo_path
              puts "Clock in photo: #{path}"
            else
              puts "No clock in photo set"
            end
          end
        end
      end
    end
  end
end
