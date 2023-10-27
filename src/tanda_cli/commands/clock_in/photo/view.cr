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
            config = Current.config

            if path = config.clockin_photo_path
              Utils::Display.print "Clock in photo: #{path}"
            else
              Utils::Display.print "No clock in photo set"
            end
          end
        end
      end
    end
  end
end
