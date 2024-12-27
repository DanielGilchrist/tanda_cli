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
    config_file = Configuration::FixtureFile.load("default")

    TandaCLI.build_context(stdin, stdout, config_file)
  end
end
