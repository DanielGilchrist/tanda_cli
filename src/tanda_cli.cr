# shards
require "option_parser"

# internal
require "./configuration"
require "./api/**"
require "./cli/**"

module Tanda::CLI
  def self.main
    config = Configuration.new
    config.parse_config!
    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      site_prefix, email, passwords = CLI::Auth.request_user_information!

      access_token = API::Auth.get_access_token!(site_prefix, email, password)
      puts "Successfully retrieved token!\n"

      config.site_prefix = site_prefix
      config.access_token.email = email
      config.access_token.token = access_token.token
      config.access_token.token_type = access_token.token_type
      config.access_token.scope = access_token.scope
      config.access_token.created_at = access_token.created_at
      config.save!
    end

    url = config.get_api_url
    token = config.token!
    client = API::Client.new(url, token)

    CLI::Parser.new(client).parse!
  end
end

{% if flag?(:debug) %}
  require "./debug"
  Tanda::CLI::Debug.setup
{% end %}

Tanda::CLI.main
