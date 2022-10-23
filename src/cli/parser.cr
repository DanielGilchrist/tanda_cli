require "colorize"

require "./commands/**"
require "../current"
require "../api/client"
require "../representers/**"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    def initialize(client : API::Client, config : Configuration)
      @client = client
      @config = config
    end

    def parse!
      OptionParser.parse do |parser|
        parser.on("me", "Get your own information") do
          me = client.me
          Representers::Me::Core.new(me).display
        end

        parser.on("time_worked", "See how many hours you've worked") do
          show = false

          OptionParser.parse do |time_worked_parser|
            time_worked_parser.on("--show", "Show shift/s") do
              show = true
            end
          end

          parser.on("today", "Time you've worked today") do
            CLI::Commands::TimeWorked::Today.new(client, show).execute
          end

          parser.on("week", "Time you've worked this week") do
            CLI::Commands::TimeWorked::Week.new(client, show).execute
          end
        end

        parser.on("time_zone", "See the currently set time zone") do
          new_time_zone : String? = nil

          OptionParser.parse do |set_time_zone_parser|
            set_time_zone_parser.on("--set=TIME_ZONE", "Set the current time zone") do |time_zone|
              new_time_zone = time_zone
            end
          end

          CLI::Commands::TimeZone.new(config, new_time_zone).execute
        end

        parser.on("current_user", "Display the current user") do
          new_id_or_name : String? = nil

          OptionParser.parse do |set_user_parser|
            set_user_parser.on("--set=ID_OR_NAME", "Set the current user") do |id_or_name|
              new_id_or_name = id_or_name
            end
          end

          CLI::Commands::CurrentUser.new(client, config, new_id_or_name).execute
        end
      end
    end

    private getter client : API::Client
    private getter config : Configuration
  end
end
