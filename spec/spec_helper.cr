require "spectator"
require "colorize"
require "webmock"

require "./core_ext/spec_mock_hack"
require "./support/config_fixture_store"
require "../src/tanda_cli"

# Makes asserting on output much easier
Colorize.enabled = false

Spectator.configure do |config|
  config.randomize = true
  config.before_each do
    WebMock.reset
  end
end

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
