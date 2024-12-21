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
          mode = context.config.mode

          if {"production", "staging"}.includes?(mode)
            puts "Mode is currently set to #{mode}"
          else
            puts "Mode is set to a custom URL (#{mode})"
          end
        end
      end
    end
  end
end
