require "../base"

module TandaCLI
  module Commands
    class StartOfWeek
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the currently set start of the week"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          Utils::Display.print "Start of the week is set to #{Current.config.pretty_start_of_week}"
        end
      end
    end
  end
end
