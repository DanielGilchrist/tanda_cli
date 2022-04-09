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
  config.parse_config!
  token = config.access_token.token

  if token.nil?
    site_prefix = begin
      puts "Site prefix:\n"
      res = gets
      res ? res.chomp : exit
    end

    email = begin
      puts "Whats your email?\n"
      res = gets
      res ? res.chomp : exit
    end

    password = begin
      puts "What's your password?\n"
      res = gets
      res ? res.chomp : exit
    end

    auth = API::Auth.new(config.site_prefix, email, password)
    auth_response = auth.get_access_token!
    puts auth_response
    parsed_auth_response = Types::PasswordAuth.from_json(auth_response)

    config.site_prefix = site_prefix
    config.access_token.email = email
    config.access_token.token = parsed_auth_response.token
    config.access_token.token_type = parsed_auth_response.token_type
    config.access_token.scope = parsed_auth_response.scope
    config.access_token.created_at = parsed_auth_response.created_at
    config.save!
  end

  url = config.get_api_url
  token = config.token!
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
