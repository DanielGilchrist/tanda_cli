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
          parser.on("today", "Time you've worked today") do
            handle_time_worked_today
          end

          parser.on("week", "Time you've worked this week") do
            list = false

            OptionParser.parse do |time_worked_parser|
              time_worked_parser.on("--list", "List days worked") do
                list = true
              end
            end

            handle_time_worked_week(list)
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

    private def handle_time_worked_today
      now = Time.local
      shifts = client.shifts(now)
      total_time_worked = calculate_time_worked(shifts)

      if total_time_worked.zero?
        puts "You haven't clocked in today"
      else
        puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
      end
    end

    private def handle_time_worked_week(list : Bool)
      now = Time.local
      shifts = client.shifts(now.at_beginning_of_week, now)
      total_time_worked = calculate_time_worked(shifts, print: list)

      if total_time_worked.zero?
        puts "You haven't clocked in this week"
      else
        puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
      end
    end

    private def calculate_time_worked(shifts : Array(Types::Shift), print : Bool = false) : Time::Span
      total_time_worked = Time::Span.zero
      shifts.each do |shift|
        time_worked = shift.time_worked
        worked_so_far = shift.worked_so_far

        print_shift(shift, time_worked, worked_so_far) if print

        total_time = time_worked || worked_so_far
        total_time_worked += total_time if total_time
      end

      total_time_worked
    end

    private def print_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?)
      time_worked && puts "Time worked: #{time_worked.hours} hours and #{time_worked.minutes} minutes"
      (!time_worked && worked_so_far) && puts "Worked so far: #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"

      Representers::Shift.new(shift).display
    end

    private getter client : API::Client
    private getter config : Configuration
  end
end
