require "../base"

module TandaCLI
  module Commands
    class Mode
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the currently set mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          mode = Current.config.mode

          if {"production", "staging"}.includes?(mode)
            Utils::Display.print "Mode is currently set to #{mode}"
          else
            Utils::Display.print "Mode is set to a custom URL (#{mode})"
          end
        end
      end
    end
  end
end
