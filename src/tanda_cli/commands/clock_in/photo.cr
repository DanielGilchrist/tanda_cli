module TandaCLI
  module Commands
    class ClockIn
      class Photo < Commands::Base
        def setup_
          @name = "photo"
          @summary = @description = "View, set or clear clockin photo to be used by default"

          add_commands(
            Photo::Clear.new,
            Photo::List.new,
            Photo::Set.new,
            Photo::View.new
          )
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          puts help_template
        end
      end
    end
  end
end
