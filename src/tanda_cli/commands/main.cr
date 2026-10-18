require "kebab"
require "./auth"
require "./me"
require "./personal_details"
require "./clock_in"
require "./config"
require "./time_worked"
require "./balance"
require "./regular_hours"
require "./current_user"
require "./mode"
require "./start_of_week"
require "./completions"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "tanda_cli", summary: "A CLI application for people using Tanda/Workforce.com")]
    struct Main
      include Kebab::Parseable

      private alias Environments = State::Serialisable::Environments
      private alias Subcommand = Auth |
                                 Me |
                                 PersonalDetails |
                                 ClockIn |
                                 TimeWorked |
                                 Balance |
                                 RegularHours |
                                 CurrentUser |
                                 Mode |
                                 StartOfWeek |
                                 Config |
                                 Completions

      def self.execute(args : Array(String), context : Context) : Nil
        case result = parse(args)
        in Main
          if result.no_colour?
            Colorize.enabled = false
            Spinner.enabled = false
          end
          maybe_display_staging_warning(context) unless skip_staging_warning?(result.command)
          result.run(context)
        in Kebab::Help
          context.display.puts(result)
        in Kebab::Errors
          context.display.puts_error(result)
          TandaCLI.fail!
        end
      end

      private def self.skip_staging_warning?(command : Subcommand) : Bool
        command.is_a?(Mode) || command.is_a?(Config) || command.is_a?(Completions)
      end

      private def self.maybe_display_staging_warning(context : Context) : Nil
        case env = context.state.current
        in Environments::Production
        in Environments::Staging
          context.display.warning("Command running in staging mode")
        in Environments::Custom
          context.display.warning("Command running on #{env.url}")
        end
      end

      @[Kebab::Option(global: true, long: "no-colour", description: "Disable ANSI colours")]
      getter? no_colour : Bool = false

      @[Kebab::Subcommand]
      getter command : Subcommand
    end
  end
end
