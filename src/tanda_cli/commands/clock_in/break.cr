module TandaCLI
  module Commands
    class ClockIn
      class Break < Commands::Base
        def setup_
          @name = "break"
          @summary = @description = "Clock a break"

          add_commands(Break::Start.new, Break::Finish.new)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          Utils::Display.print help_template
        end
      end
    end
  end
end
