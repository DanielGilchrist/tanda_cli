require "./executors/**"
require "./parser/helpers"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    include CLI::Parser::Helpers

    def self.parse!(args : Array(String) = ARGV)
      new(args).parse!
    end

    def initialize(@args : Array(String) = ARGV); end

    def parse!
      OptionParser.parse(@args) do |parser|
        parser.banner = "Usage: tanda_cli [arguments]"

        parse_standard_options!(parser)
        maybe_display_staging_warning

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

      parser.on("mode", "Set the mode to run commands in (production/staging/custom <url>)") do
        CLI::Parser::Mode.new(parser).parse
      end

      parser.on("start_of_week", "Set the start of the week (e.g. monday/sunday)") do
        CLI::Parser::StartOfWeek.new(parser).parse
      end
    end
  end
end
