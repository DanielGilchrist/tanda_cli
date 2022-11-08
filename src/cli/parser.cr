require "./commands/**"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    def initialize(@client : API::Client, @config : Configuration, @args = ARGV); end

    def parse!
      OptionParser.parse(args) do |parser|
        parser.on("me", "Get your own information") do
          me = client.me
          Representers::Me::Core.new(me).display
        end

        parser.on("time_worked", "See how many hours you've worked") do
          CLI::Parser::TimeWorked.new(parser, client).parse
        end

        parser.on("clockin", "Clock in/out") do
          CLI::Parser::ClockIn.new(parser, client).parse
        end

        parser.on("time_zone", "See the currently set time zone") do
          CLI::Parser::TimeZone.new(parser, config).parse
        end

        parser.on("current_user", "Display the current user") do
          CLI::Parser::CurrentUser.new(parser, config).parse
        end

        parser.on("mode", "Set the mode to run commands in (production/staging/custom <url>") do
          CLI::Parser::Mode.new(parser, config).parse
        end
      end
    end

    private getter args : Array(String)
    private getter client : API::Client
    private getter config : Configuration
  end
end
