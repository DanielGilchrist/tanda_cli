module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Photo
        class Set < CLI::Commands::Base
          def on_setup
            @name = "set"
            @summary = @description = "Set a default clockin photo or directory of photos"

            add_argument "path", description: "Path to the photo or directory of photos to set", required: true
          end

          def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
            path = arguments.get("path").as_s

            if !Models::PhotoPathParser.valid?(path)
              Utils::Display.error!("Invalid photo path")
            end

            config = Current.config
            config.clockin_photo_path = path
            config.save!

            Utils::Display.success("Clock in photo set to \"#{path}\"")
          end
        end
      end
    end
  end
end
