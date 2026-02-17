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

          case mode
          when "production"
            display.puts "#{"Production".colorize.green}"
          when "staging"
            display.puts "#{"Staging".colorize.yellow}"
          else
            display.puts "#{"Custom".colorize.cyan} (#{mode})"
          end
        end
      end
    end
  end
end
