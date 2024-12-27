require "spec"
require "colorize"
require "webmock"

require "../src/tanda_cli"
require "./support/configuration/fixture_file"
require "./support/command"

# Makes asserting on output much easier
Colorize.enabled = false

Spec.before_each do
  WebMock.reset
end

BASE_URI = "https://fakeurlthisisfakenotrealahhhh.com/api/v2"

def endpoint(path, query = nil)
  uri = URI.parse("#{BASE_URI}#{path}")
  uri.query = URI::Params.encode(query) if query

  uri.to_s
end
