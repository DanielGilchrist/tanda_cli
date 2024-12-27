module TandaCLI
  module Commands
    class ClockIn
      class Photo
        class Clear < Commands::Base
          def setup_
            @name = "clear"
            @summary = @description = "Clear set clockin photo or directory"
          end

          def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
            config.clockin_photo_path = nil
            config.save!

            display.success("Clock in photo cleared")
          end
        end
      end
    end
  end
end
