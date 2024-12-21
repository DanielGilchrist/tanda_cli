# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args = ARGV)
    {% if flag?(:debug) %}
      TandaCLI::Debug.setup
    {% end %}

    io = IO::Memory.new
    config = Configuration.init
    client = build_client(config)
    current_user = CurrentUser.new(config, client).fetch
    current = Current.new(current_user)
    context = Context.new(
      io,
      config,
      client,
      current
    )

    Commands::Main.new(context).execute(args)

    puts io
  end

  def build_client(config : Configuration) : API::Client
    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      API::Auth.fetch_new_token!
      return create_client_from_config
    end

    url = config.api_url
    API::Client.new(url, token)
  end
end

# Tests should call this explicitly
{% unless flag?(:test) %}
  TandaCLI.main
{% end %}
