module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Display the currently set mode")]
      struct Display
        include Kebab::Parseable

        private alias Environments = State::Serialisable::Environments

        def run(context : Context) : Nil
          display = context.display

          case env = context.state.current
          in Environments::Production
            display.puts env.display_label.colorize.green
          in Environments::Staging
            display.puts env.display_label.colorize.yellow
          in Environments::Custom
            display.puts env.display_label.colorize.cyan
          end
        end
      end
    end
  end
end
