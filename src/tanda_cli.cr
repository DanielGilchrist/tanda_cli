# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args : Array(String), stdin : IO, stdout : IO, stderr : IO, config_file : Configuration::AbstractFile) : Context
    build_context(stdin, stdout, stderr, config_file).tap do |context|
      Commands::Main.execute(args, context)
    rescue ExitProgram
    rescue ex
      {% if flag?(:debug) && !flag?(:test) %}
        raise ex
      {% else %}
        context.display.error(ex.message || "An error occurred")
      {% end %}
    end
  ensure
    config_file.close
  end

  def exit! : NoReturn
    raise(ExitProgram.new)
  end

  private def build_context(stdin : IO, stdout : IO, stderr : IO, config_file : Configuration::AbstractFile) : Context
    display = Display.new(stdout, stderr)
    input = Input.new(stdin, display)
    config = Configuration.init(config_file, display)
    current_user = user_from_config(config)
    client = build_client(config, current_user)
    current = Current.new(current_user) if current_user

    Context.new(config, client, current, display, input)
  end

  private def build_client(config : Configuration, current_user : Current::User? = nil) : API::Client?
    access_token = config.access_token
    return unless access_token

    API::Client.new(config.api_url, access_token.token, current_user)
  end

  private def user_from_config(config : Configuration) : Current::User?
    organisation = config.current_organisation?
    return if organisation.nil?

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
