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

        parser.on("time_worked", "See how many hours you've worked this week") do
          handle_time_worked
        end
      end
    end

    private def handle_time_worked
      now = Time.local
      start_date, finish_date = [
        now.at_beginning_of_week,
        now
      ]
      .map(&.to_s("%Y-%m-%d"))

      response = client.get("/shifts", query: {
        "user_ids" => "66585",
        "from"     => start_date,
        "to"       => finish_date
      })

      total_time_worked = Time::Span.zero
      Array(Types::Shift).from_json(response.body).each do |shift|
        time_worked = shift.time_worked
        worked_so_far = shift.worked_so_far
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

        total_time = time_worked || worked_so_far
        total_time_worked += total_time if total_time
      end

      puts("Total time worked so far: #{total_time_worked.total_hours.to_i} hours and #{total_time_worked.minutes} minutes")
    end

    private getter client : API::Client
  end
end
