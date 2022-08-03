require "../api/client"
require "../representers/me"
require "../types/**"

module Tanda::CLI
  class CLI::Parser
    def initialize(client : API::Client)
      @client = client
    end

    def parse!
      OptionParser.parse do |parser|
        parser.on("me", "Get your own information") do
          response = client.get("/users/me").body
          parsed_response = Types::Me::Core.from_json(response)
          Representers::Me.new(parsed_response).display
        end

        parser.on("time_worked", "See how many hours you've worked") do
          list = false

          parser.on("week", "Time you've worked this week") do
            OptionParser.parse do |time_worked_parser|
              time_worked_parser.on("--list", "List days worked") do
                list = true
              end
            end

            handle_time_worked_week(list)
          end

          parser.on("today", "Time you've worked today") do
            handle_time_worked_today
          end
        end
      end
    end

    private def handle_time_worked_today
      now = Time.local
      shifts = request_shifts(now, now)
      total_time_worked = calculate_time_worked(shifts)

      if total_time_worked.zero?
        puts "You haven't clocked in today"
      else
        puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes today")
      end
    end

    private def handle_time_worked_week(list : Bool)
      now = Time.local
      shifts = request_shifts(now.at_beginning_of_week, now)
      total_time_worked = calculate_time_worked(shifts, print: list)

      if total_time_worked.zero?
        puts "You haven't clocked in this week"
      else
        puts("You've worked #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes this week")
      end
    end

    private def request_shifts(start_date : Time, finish_date : Time)
      start_string, finish_string = [
        start_date,
        finish_date
      ]
      .map(&.to_s("%Y-%m-%d"))

      response = client.get("/shifts", query: {
        "user_ids" => "66585", # TODO: Don't hard-code this
        "from"     => start_string,
        "to"       => finish_string
      })

      Array(Types::Shift).from_json(response.body)
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

    def print_shift(shift : Types::Shift, time_worked : Time::Span?, worked_so_far : Time::Span?)
      time_worked && puts "Time worked: #{time_worked.hours} hours and #{time_worked.minutes} minutes"
      (!time_worked && worked_so_far) && puts "Worked so far: #{worked_so_far.hours} hours and #{worked_so_far.minutes} minutes"

      puts "ID: #{shift.id}"
      puts "User ID: #{shift.user_id}"
      puts "Start: #{shift.start}"
      puts "Finish: #{shift.finish}"
      puts "Status: #{shift.status}"
      puts "Breaks:"
      shift.breaks.each do |shift_break|
        puts "  ID: #{shift_break.id}"
        puts "  Shift ID: #{shift_break.shift_id}"
        puts "  Start: #{shift_break.start}"
        puts "  Finish: #{shift_break.finish}"
        puts "  Length: #{shift_break.length}"
      end
      puts "\n"
    end

    private getter client : API::Client
  end
end
