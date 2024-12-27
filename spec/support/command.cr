module Command
  extend self

  def run(args : Array(String), stdin : IO = IO::Memory.new) : TandaCLI::Context
    context = build_context(stdin)
    execute(context, args)

    context
  end

  def run(args : Array(String), stdin : IO = IO::Memory.new, & : TandaCLI::Context -> Nil) : TandaCLI::Context
    context = build_context(stdin)
    yield(context)
    execute(context, args)

    context
  end

  private def execute(context : TandaCLI::Context, args : Array(String))
    TandaCLI::Commands::Main.new(context).execute(args)
  end

  private def build_context(stdin : IO) : TandaCLI::Context
    stdout = IO::Memory.new
    display = TandaCLI::Display.new(stdout)
    input = TandaCLI::Input.new(stdin, display)
    config = Configuration::FixtureFile.load_fixture("default", display)
    current_user = TandaCLI::Current::User.new(1, "Test")
    current = TandaCLI::Current.new(current_user)
    client = TandaCLI::API::Client.new(
      base_uri: BASE_URI,
      token: config.access_token.token.not_nil!,
      display: display,
      current_user: current_user
    )

    TandaCLI::Context.new(
      stdout,
      config,
      client,
      current,
      display,
      input
    )
  end
end
