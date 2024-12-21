module TandaCLI
  module Commands
    class ClockIn
      class Photo
        class View < Commands::Base
          def setup_
            @name = "view"
            @summary = @description = "View the currently set clockin photo or directory"
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            config = context.config

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
