require "spectator"
require "../src/tanda_cli"

Spectator.configure do |config|
  config.randomize = true
  config.before_each do
    TandaCLI::Current.reset!
  end
end
