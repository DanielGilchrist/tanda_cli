# stdlib
require "colorize"
require "file_utils"
require "http"
require "json"
require "log"
require "uri"

# shards
require "cling"
require "term-prompt"

require "./ext/**"

# Load dependencies first to establish proper load order
require "./tanda_cli/error/interface"
require "./tanda_cli/abstract_result"
require "./tanda_cli/utils/mixins/pretty_times"
require "./tanda_cli/types/**"
require "./tanda_cli/commands/required_scopes"
require "./tanda_cli/commands/help"
require "./tanda_cli/commands/base"

require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args : Array(String), stdin : IO, stdout : IO, stderr : IO, config_file : Configuration::AbstractFile) : Context
    build_context(stdin, stdout, stderr, config_file).tap do |context|
      Commands::Main.new(context).execute(args)
    end
  ensure
    config_file.close
  end

  def exit! : NoReturn
    raise(Cling::ExitProgram.new(0))
  end

  private def build_context(stdin : IO, stdout : IO, stderr : IO, config_file : Configuration::AbstractFile) : Context
    display = Display.new(stdout, stderr)
    input = Input.new(stdin, display)
    config = Configuration.init(config_file, display)
    current_user = user_from_config(config) || user_from_api(config, display, input)
    client = build_client(config, display, input, current_user)
    current = Current.new(current_user)

    Context.new(
      config,
      client,
      current,
      display,
      input
    )
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
  {% if flag?(:debug) %}
    TandaCLI::Debug.setup
  {% end %}

  TandaCLI.main(
    args: ARGV,
    stdout: STDOUT,
    stdin: STDIN,
    stderr: STDERR,
    config_file: TandaCLI::Configuration::File.new
  )
{% end %}
