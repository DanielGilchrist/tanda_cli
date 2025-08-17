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
            message = begin
              if path = config.clockin_photo_path
                "Clock in photo: #{path}"
              else
                "No clock in photo set"
              end
            end

            display.puts message
          end
        end
      end
    end
  end
end
