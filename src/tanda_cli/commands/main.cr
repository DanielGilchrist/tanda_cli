require "../../../kebab/src/kebab"
require "./auth"
require "./me"
require "./personal_details"
require "./clock_in"
require "./time_worked"
require "./balance"
require "./regular_hours"
require "./current_user"
require "./mode"
require "./start_of_week"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "tanda_cli", summary: "A CLI application for people using Tanda/Workforce.com")]
    struct Main
      include Kebab::Parseable

      private alias Environment = Configuration::Serialisable::Environment

      def self.execute(args : Array(String), context : Context) : Nil
        case result = parse(args)
        in Main
          Colorize.enabled = false if result.no_colour?
          maybe_display_staging_warning(context, result.command)
          result.run(context)
        in Kebab::Help
          context.display.puts(result)
        in Kebab::Errors
          context.display.puts_error(result)
          TandaCLI.exit!
        end
      end

      private def self.maybe_display_staging_warning(context : Context, command) : Nil
        return if command.is_a?(Mode)

        case env = context.config.current
        in Environment::Production
        in Environment::Staging
          context.display.warning("Command running in staging mode")
        in Environment::Custom
          context.display.warning("Command running on #{env.url}")
        end
      end

      @[Kebab::Option(long: "no-colour", description: "Disable ANSI colours")]
      getter? no_colour : Bool = false

      @[Kebab::Subcommand]
      getter command : Auth | Me | PersonalDetails | ClockIn | TimeWorked | Balance | RegularHours | CurrentUser | Mode | StartOfWeek
    end
  end
end
