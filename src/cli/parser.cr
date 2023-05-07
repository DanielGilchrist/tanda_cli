require "./commands/**"
require "./parser/helpers"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    include CLI::Parser::Helpers

    def self.parse!(args = ARGV)
      new(args).parse!
    end

    def initialize(@args = ARGV); end

    def parse!
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: tanda_cli [arguments]"

        parse_standard_options!(parser)
        maybe_display_staging_warning
        parse_api_options!(parser)

        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end

        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end
    end

    private getter args : Array(String)

    # Options that don't make API requests
    private def parse_standard_options!(parser : OptionParser)
      parser.on("time_zone", "See the currently set time zone") do
        maybe_display_staging_warning
        CLI::Parser::TimeZone.new(parser).parse
      end

      parser.on("current_user", "Display the current user") do
        maybe_display_staging_warning
        CLI::Parser::CurrentUser.new(parser).parse
      end

      parser.on("mode", "Set the mode to run commands in (production/staging/custom <url>") do
        CLI::Parser::Mode.new(parser).parse
      end

      parser.on("start_of_week", "Set the start of the week (e.g. monday/sunday)") do
        CLI::Parser::StartOfWeek.new(parser).parse
      end
    end

    # Options that make API requests
    private def parse_api_options!(parser : OptionParser)
      parser.on("me", "Get your own information") do
        me = build_client_with_current_user.me.or(&.display!)
        Representers::Me.new(me).display
      end

      parser.on("personal_details", "Get your personal details") do
        personal_details = build_client_with_current_user.personal_details.or(&.display!)
        Representers::PersonalDetails.new(personal_details).display
      end

      parser.on("time_worked", "See how many hours you've worked") do
        CLI::Parser::TimeWorked.new(parser, ->{ build_client_with_current_user }).parse
      end

      parser.on("clockin", "Clock in/out") do
        CLI::Parser::ClockIn.new(parser, ->{ build_client_with_current_user }).parse
      end

      parser.on("balance", "Check your leave balances") do
        CLI::Parser::LeaveBalance.new(parser, ->{ build_client_with_current_user }).parse
      end

      parser.on("regular_hours", "View or set your regular hours") do
        CLI::Parser::RegularHours.new(parser, ->{ build_client_with_current_user }).parse
      end

      parser.on("refetch_token", "Refetch token for the current environment") do
        config = Current.config
        config.reset_environment!
        API::Auth.fetch_new_token!

        client = create_client_from_config
        CLI::Request.ask_which_organisation_and_save!(client, config)
        exit
      end

      parser.on("refetch_users", "Refetch users from the API and save to config") do
        CLI::Request.ask_which_organisation_and_save!(build_client_with_current_user, Current.config)
        exit
      end
    end
  end
end
