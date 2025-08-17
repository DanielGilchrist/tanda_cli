require "../base"

module TandaCLI
  module Commands
    class Mode
      class Display < Base
        @disable_staging_warning = true

        def setup_
          @name = "display"
          @summary = @description = "Display the currently set mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          mode = config.mode

          message = begin
            if {"production", "staging"}.includes?(mode)
              "Mode is currently set to #{mode}"
            else
              "Mode is set to a custom URL (#{mode})"
            end
          end

          display.puts message
        end
      end
    end
  end
end
