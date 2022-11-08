# shards
require "option_parser"

# internal
require "./configuration"
require "./current"
require "./utils/**"
require "./api/**"
require "./cli/**"

module Tanda::CLI
  extend self

  def try_parse_config!(config : Configuration)
    config.parse_config!
  rescue error
    {% if flag?(:debug) %}
      raise(error)
    {% else %}
      value = error.message.try(&.split("\n").first) if error.is_a?(JSON::SerializableError)
      reason = " (#{value})" if value
      Utils::Display.error("Invalid Config#{reason}")
      exit
    {% end %}
  end

  def main
    config = Configuration.new
    try_parse_config!(config)

    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      site_prefix, email, password = CLI::Auth.request_user_information!

      access_token = API::Auth.fetch_access_token!(site_prefix, email, password)
      if access_token.is_a?(Types::AccessToken)
        Utils::Display.success("Retrieved token!\n")
      else
        # TODO - Crystal compiler bug
        # .as needed due to bug https://github.com/crystal-lang/crystal/issues/10831
        error = access_token.as(Types::Error)
        Utils::Display.error("Unable to authenticate (likely incorrect login details)")
        Utils::Display.sub_error("Error Type: #{error.error}")

        description = error.error_description
        Utils::Display.sub_error("Message: #{description}") if description

        exit
      end

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
