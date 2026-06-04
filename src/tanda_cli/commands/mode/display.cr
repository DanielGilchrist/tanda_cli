require "../base"

module TandaCLI
  module Commands
    class Mode
      class Display < Base
        disable_staging_warning!

        def setup_
          @name = "display"
          @summary = @description = "Display the currently set mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          case mode = config.mode
          in Configuration::Mode::Production
            display.puts mode.display_label.colorize.green
          in Configuration::Mode::Staging
            display.puts mode.display_label.colorize.yellow
          in Configuration::Mode::Custom
            display.puts mode.display_label.colorize.cyan
          end
        end
      end
    end
  end
end
