module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Photo
        class Clear < CLI::Commands::Base
          def setup_
            @name = "clear"
            @summary = @description = "Clear set clockin photo or directory"
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            config = Current.config
            config.clockin_photo_path = nil
            config.save!

            Utils::Display.success("Clock in photo cleared")
          end
        end
      end
    end
  end
end
