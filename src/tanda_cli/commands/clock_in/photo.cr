module TandaCLI
  module Commands
    class ClockIn
      class Photo < Commands::Base
        def setup_
          @name = "photo"
          @summary = @description = "View, set or clear clockin photo to be used by default"

          add_commands(
            Photo::Set.new,
            Photo::View.new,
            Photo::Clear.new
          )
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          Utils::Display.print help_template
        end
      end
    end
  end
end
