module TandaCLI
  module Commands
    class ClockIn
      class Photo < Commands::Base
        def setup_
          @name = "photo"
          @summary = @description = "View, set or clear clockin photo to be used by default"

          add_commands(
            Photo::Clear,
            Photo::List,
            Photo::Set,
            Photo::View
          )
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          stdout.puts help_template
        end
      end
    end
  end
end
