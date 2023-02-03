require "./commands/**"
require "./parser/helpers"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    include CLI::Parser::Helpers

    def initialize(@config : Configuration, @args = ARGV); end

    def parse!
      OptionParser.parse(args) do |parser|
        parse_standard_options!(parser)
        maybe_display_staging_warning
        parse_api_options!(parser)
      end
    end

    private getter config : Configuration
    private getter args : Array(String)

    # Options that don't make API requests
    private def parse_standard_options!(parser : OptionParser)
      parser.on("time_zone", "See the currently set time zone") do
        maybe_display_staging_warning
        CLI::Parser::TimeZone.new(parser, config).parse
      end

      parser.on("current_user", "Display the current user") do
        maybe_display_staging_warning
        CLI::Parser::CurrentUser.new(parser, config).parse
      end

      parser.on("mode", "Set the mode to run commands in (production/staging/custom <url>") do
        CLI::Parser::Mode.new(parser, config).parse
      end
    end

    # Options that make API requests
    private def parse_api_options!(parser : OptionParser)
      parser.on("me", "Get your own information") do
        me = build_client_with_current_user.me.or(&.display!)
        Representers::Me.new(me).display
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

      parser.on("refetch_token", "Refetch token for the current environment") do
        config.reset_environment!
        fetch_new_token!

        client = create_client_from_config
        CLI::Request.ask_which_organisation_and_save!(client, config)
        exit
      end

      parser.on("refetch_users", "Refetch users from the API and save to config") do
        CLI::Request.ask_which_organisation_and_save!(build_client_with_current_user, config)
        exit
      end
    end
  end
end
