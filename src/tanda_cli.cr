# shards
require "colorize"
require "option_parser"

# internal
require "./configuration"
require "./current"
require "./api/**"
require "./cli/**"

module Tanda::CLI
  def self.try_parse_config!(config : Configuration)
    config.parse_config!
  rescue error
    {% if flag?(:debug) %}
      raise(error)
    {% else %}
      puts "\n#{"Error:".colorize(:red)} Invalid Config!"
      puts error.message.try(&.split("\n").first) if error.is_a?(JSON::SerializableError)
      exit
    {% end %}
  end

  def self.main
    config = Configuration.new
    try_parse_config!(config)

    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      site_prefix, email, password = CLI::Auth.request_user_information!

      access_token = API::Auth.get_access_token!(site_prefix, email, password)
      puts "Successfully retrieved token!\n"

      config.overwrite!(site_prefix, email, access_token)
    end

    url = config.get_api_url
    token = config.token!
    client = API::Client.new(url, token)

    CLI::CurrentUser.new(client, config).set!
    CLI::Parser.new(client, config).parse!
  end
end

{% if flag?(:debug) %}
  require "./debug"
  Tanda::CLI::Debug.setup
{% end %}

# TODO: Test `Tanda::CLI.main`
{% unless flag?(:test) %}
  Tanda::CLI.main
{% end %}
