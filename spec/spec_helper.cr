require "spectator"
require "webmock"

require "../src/tanda_cli"

Spectator.configure do |config|
  config.randomize = true
  config.before_each do
    TandaCLI::Current.reset!
    WebMock.reset
  end
end
