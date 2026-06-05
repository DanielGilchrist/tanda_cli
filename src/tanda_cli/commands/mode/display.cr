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
          case env = config.current
          in Configuration::Serialisable::Environment::Production
            display.puts env.display_label.colorize.green
          in Configuration::Serialisable::Environment::Staging
            display.puts env.display_label.colorize.yellow
          in Configuration::Serialisable::Environment::Custom
            display.puts env.display_label.colorize.cyan
          end
        end
      end
    end
  end
end
