module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Display the currently set mode")]
      struct Display
        include Kebab::Parseable

        private alias Environment = Configuration::Serialisable::Environment

        def run(context : Context) : Nil
          display = context.display

          case env = context.config.current
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
