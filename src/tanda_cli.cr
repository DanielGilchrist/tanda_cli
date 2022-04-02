# shards
require "option_parser"

# internal
require "./api/client"
require "./api/configuration"
require "./representers/me"
require "./types/me/**"

module Tanda::CLI
  VERSION = "0.1.0"

  TOKEN = ""

  config = API::Configuration.new(API::Configuration::ServerCountry::EU)
  client = API::Client.new(TOKEN, config)

  OptionParser.parse do |parser|
    parser.banner = "Welcome to the Tanda CLI!"

    parser.on("me", "Get your own information") do
      response = client.get("/users/me").body
      parsed_response = Types::Me::Core.from_json(response)
      Representers::Me.new(parsed_response).display
    end
  end
end
