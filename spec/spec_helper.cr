require "spec"
require "colorize"
require "webmock"

require "./support/config_fixture_store"
require "../src/tanda_cli"

# Makes asserting on output much easier
Colorize.enabled = false

Spec.before_each &->WebMock.reset

BASE_URI = "https://fakeurlthisisfakenotrealahhhh.com/api/v2"

def endpoint(path)
  "#{BASE_URI}#{path}"
end

def run_command(args : Array(String))
  io = IO::Memory.new

  config = ConfigFixtureStore.load_fixture("default")
  current_user = TandaCLI::Current::User.new(1, "Test")
  current = TandaCLI::Current.new(current_user)
  client = TandaCLI::API::Client.new(
    base_uri: BASE_URI,
    token: config.access_token.token.not_nil!,
    current_user: current_user
  )
  context = TandaCLI::Context.new(
    io,
    config,
    client,
    current
  )

  TandaCLI::Commands::Main.new(context).execute(args)

  io.to_s
end
