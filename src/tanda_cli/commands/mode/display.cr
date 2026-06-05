require "../base"

module TandaCLI
  module Commands
    class Mode
      class Display < Base
        private alias Environment = Configuration::Serialisable::Environment

        disable_staging_warning!

        def setup_
          @name = "display"
          @summary = @description = "Display the currently set mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          case env = config.current
          in Environment::Production
            display.puts env.display_label.colorize.green
          in Environment::Staging
            display.puts env.display_label.colorize.yellow
          in Environment::Custom
            display.puts env.display_label.colorize.cyan
          end
        end
      end
    end
  end
end
