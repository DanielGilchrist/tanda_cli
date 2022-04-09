require "../api/client"
require "../representers/me"
require "../types/me/core"

module Tanda::CLI
  class CLI::Parser
    def initialize(client : API::Client)
      @client = client
    end

    def parse!
      OptionParser.parse do |parser|
        parser.banner = "Welcome to the Tanda CLI!"

        parser.on("me", "Get your own information") do
          response = client.get("/users/me").body
          parsed_response = Types::Me::Core.from_json(response)
          Representers::Me.new(parsed_response).display
        end
      end
    end

    private getter client : API::Client
  end
end
