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
          response = client.get("/shifts", query: {
            "user_ids" => "66585",
            "from"     => "2022-04-04",
            "to"       => "2022-04-09"
          })

          puts response.body

          Array(Types::Shift).from_json(response.body).each do |shift|
            puts "ID: #{shift.id}"
            puts "User ID: #{shift.user_id}"
            puts "Start: #{shift.start}"
            puts "Finish: #{shift.finish}"
            puts "Status: #{shift.status}"
            puts "\n"
          end
        end
      end
    end

    private getter client : API::Client
  end
end
