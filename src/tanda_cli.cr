# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  class Exit < Exception; end

  def exit! : NoReturn
    raise(Cling::ExitProgram.new(0))
  end

  def main(args = ARGV, output_io = STDOUT)
    {% if flag?(:debug) && !flag?(:test) %}
      TandaCLI::Debug.setup
    {% end %}

    io = IO::Memory.new
    store = Configuration::FileStore.new

    config = Configuration.init(store)
    client = build_client(config)
    current_user = user_from_config(config) || user_from_api(config)
    current = Current.new(current_user)
    context = Context.new(
      io,
      config,
      client,
      current
    )

    Commands::Main.new(context).execute(args)
  ensure
    store.try(&.close)
    output_io.puts io if io && !io.empty?
  end

  private def build_client(config : Configuration, current_user : Current::User? = nil) : API::Client
    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      API::Auth.fetch_new_token!(config)
      return build_client(config)
    end

    url = config.api_url
    API::Client.new(url, token, current_user)
  end

  private def user_from_config(config : Configuration) : Current::User?
    organisation = config.current_organisation?
    return if organisation.nil?

    Current::User.new(organisation.user_id, organisation.name)
  end

  private def user_from_api(config : Configuration) : Current::User
    client = build_client(config)
    organisation = Request.ask_which_organisation_and_save!(client, config)

    Current::User.new(organisation.user_id, organisation.name)
  end
end

# Tests should call this explicitly
{% unless flag?(:test) %}
  TandaCLI.main
{% end %}
