# shards
require "option_parser"

# internal
require "./configuration"
require "./api/**"
require "./representers/me"
require "./types/**"

module Tanda::CLI
  VERSION = "0.1.0"

  config = Configuration.new

  # auth = API::Auth.new
  # auth_response = auth.get_password_response("", "")
  # puts auth_response
  # parsed_auth_response = Types::PasswordAuth.from_json(auth_response)
  # puts parsed_auth_response.token

  token = config.access_token.token
  raise "Token is missing" if token.nil?

  client = API::Client.new(config.get_api_url, token)

  OptionParser.parse do |parser|
    parser.banner = "Welcome to the Tanda CLI!"

    parser.on("me", "Get your own information") do
      response = client.get("/users/me").body
      parsed_response = Types::Me::Core.from_json(response)
      Representers::Me.new(parsed_response).display
    end
  end
end
