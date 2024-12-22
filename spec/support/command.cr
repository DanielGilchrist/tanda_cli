module Command
  extend self

  def run(args : Array(String)) : TandaCLI::Context
    context = build_context
    execute(context, args)

    context
  end

  def run(args : Array(String), & : TandaCLI::Context -> Nil) : TandaCLI::Context
    context = build_context
    yield(context)
    execute(context, args)

    context
  end

  private def execute(context : TandaCLI::Context, args : Array(String))
    TandaCLI::Commands::Main.new(context).execute(args)
  end

  private def build_context : TandaCLI::Context
    io = IO::Memory.new
    config = ConfigFixtureStore.load_fixture("default")
    current_user = TandaCLI::Current::User.new(1, "Test")
    current = TandaCLI::Current.new(current_user)
    client = TandaCLI::API::Client.new(
      base_uri: BASE_URI,
      token: config.access_token.token.not_nil!,
      current_user: current_user
    )

    TandaCLI::Context.new(
      io,
      config,
      client,
      current
    )
  end
end
