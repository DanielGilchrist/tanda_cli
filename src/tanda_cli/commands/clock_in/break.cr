module TandaCLI
  module Commands
    class ClockIn
      class Break < Commands::Base
        def setup_
          @name = "break"
          @summary = @description = "Clock a break"

          add_commands(Break::Start, Break::Finish)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          io.puts help_template
        end
      end
    end
  end
end
