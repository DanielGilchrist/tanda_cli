require "./commands/**"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    def initialize(@config : Configuration, @args = ARGV); end

    def parse!
      # This should exit early if a command is successfully parsed
      parse_standard_options!

      maybe_display_staging_warning

      client = create_client_from_config
      CLI::CurrentUser.new(client, config).set!

      parse_api_options!(client)
    end

    private getter config : Configuration
    private getter args   : Array(String)

    # Options that don't make API requests
    private def parse_standard_options!
      OptionParser.parse(args) do |parser|
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

        parser.invalid_option do
          # TODO: Handle invalid options
          # no-op
        end
      end
    end

    # Options that make API requests
    private def parse_api_options!(client : API::Client)
      OptionParser.parse(args) do |parser|
        parser.on("me", "Get your own information") do
          me = client.me.or(&.display!)
          Representers::Me::Core.new(me).display
        end

        parser.on("time_worked", "See how many hours you've worked") do
          CLI::Parser::TimeWorked.new(parser, client).parse
        end

        parser.on("clockin", "Clock in/out") do
          CLI::Parser::ClockIn.new(parser, client).parse
        end

        parser.on("refetch_token", "Refetch token for the current environment") do
          config.reset_environment!
          fetch_new_token!
        end
      end
    end

    private def maybe_display_staging_warning
      return unless config.staging?

      message = if (mode = config.mode != "staging")
        "Command running on #{mode}"
      else
        "Command running in staging mode"
      end

      Utils::Display.warning(message)
    end

    private def create_client_from_config : API::Client
      token = config.access_token.token

      # if a token can't be parsed from the config, get username and password from user and request a token
      fetch_new_token! if token.nil?

      url = config.get_api_url
      token = config.token!
      API::Client.new(url, token)
    end

    private def fetch_new_token!
      site_prefix, email, password = CLI::Auth.request_user_information!

      auth_site_prefix = if config.staging?
        case site_prefix
        when "my"
          "staging"
        when "eu"
          "staging.eu"
        when "us"
          "staging.us"
        end
      end || site_prefix

      API::Auth.fetch_access_token!(auth_site_prefix, email, password).match do
        ok do |access_token|
          Utils::Display.success("Retrieved token!#{config.staging? ? " (staging)" : ""}\n")
          config.overwrite!(site_prefix, email, access_token)
        end

        error do |error|
          Utils::Display.error!("Unable to authenticate (likely incorrect login details)") do |sub_errors|
            sub_errors << "Error Type: #{error.error}\n"

            description = error.error_description
            sub_errors << "Message: #{description}" if description
          end
        end
      end
    end
  end
end
