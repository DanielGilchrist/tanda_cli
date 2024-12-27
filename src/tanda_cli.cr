# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args = ARGV, stdin = STDIN, stdout = STDOUT, config_file = Configuration::File.new)
    {% if flag?(:debug) && !flag?(:test) %}
      TandaCLI::Debug.setup
    {% end %}

    context = build_context(stdin, stdout, config_file)
    Commands::Main.new(context).execute(args)
  ensure
    config_file.close
  end

  def build_context(stdin : IO, stdout : IO, config_file : Configuration::AbstractFile) : Context
    display = Display.new(stdout)
    input = Input.new(stdin, display)
    config = Configuration.init(config_file, display)
    client = build_client(config, display, input)
    current_user = user_from_config(config) || user_from_api(config, display, input)
    current = Current.new(current_user)

    Context.new(
      stdout,
      config,
      client,
      current,
      display,
      input
    )
  end

  def exit! : NoReturn
    raise(Cling::ExitProgram.new(0))
  end

  private def build_client(config : Configuration, display : Display, input : Input, current_user : Current::User? = nil) : API::Client
    token = config.access_token.token

    # if a token can't be parsed from the config, get username and password from user and request a token
    if token.nil?
      API::Auth.fetch_new_token!(config, display, input)
      return build_client(config, display, input)
    end

    url = config.api_url
    display.error!(url) unless url.is_a?(String)
    API::Client.new(url, token, display, current_user)
  end

  private def user_from_config(config : Configuration) : Current::User?
    organisation = config.current_organisation?
    return if organisation.nil?

    Current::User.new(organisation.user_id, organisation.name)
  end

  private def user_from_api(config : Configuration, display : Display, input : Input) : Current::User
    client = build_client(config, display, input)
    organisation = Request.ask_which_organisation_and_save!(client, config, display, input)

    Current::User.new(organisation.user_id, organisation.name)
  end
end

{% unless flag?(:test) %}
  TandaCLI.main
{% end %}
