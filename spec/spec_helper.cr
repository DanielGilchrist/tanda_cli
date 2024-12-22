require "spec"
require "colorize"
require "webmock"

require "./support/config_fixture_store"
require "../src/tanda_cli"
require "./support/command"

# Makes asserting on output much easier
Colorize.enabled = false

Spec.before_each do
  WebMock.reset
end

BASE_URI = "https://fakeurlthisisfakenotrealahhhh.com/api/v2"

def endpoint(path)
  "#{BASE_URI}#{path}"
end
