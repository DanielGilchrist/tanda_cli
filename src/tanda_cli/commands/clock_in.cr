require "../ext/kebab"
require "./clock_in/*"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "clockin", summary: "Clock in/out")]
    struct ClockIn
      include Kebab::Serialisable

      private alias Environment = Configuration::Serialisable::Environment

      def self.execute(args : Array(String), context : Context) : Nil
        display = context.display

        case result = parse(args)
        in ClockIn
          maybe_display_staging_warning(context)
          result.run(context)
        in Kebab::Error::HelpRequested
          display.puts(result.help)
        in Kebab::Error::Base
          display.error!(result)
        end
      end

      private def self.maybe_display_staging_warning(context : Context) : Nil
        case env = context.config.current
        in Environment::Production
          # no warning needed
        in Environment::Staging
          context.display.warning("Command running in staging mode")
        in Environment::Custom
          context.display.warning("Command running on #{env.url}")
        end
      end

      @[Kebab::Subcommand]
      getter command : Start | Finish | Break | Backfill | Photo | Status | Display | Nil

      def run(context : Context) : Nil
        if command = @command
          command.run(context)
        else
          context.display.puts(__kebab_help_text)
        end
      end
    end
  end
end
