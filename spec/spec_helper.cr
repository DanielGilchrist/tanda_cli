require "spec"
require "colorize"
require "webmock"

require "../src/tanda_cli"
require "./support/travel_to_hack"
require "./support/configuration/fixture_file"
require "./support/command"

# Makes asserting on output much easier
Colorize.enabled = false

Spec.before_each do
  WebMock.reset
end

Spec.after_each do
  TandaCLI::Utils::Time.reset!
end

BASE_URI = "https://fakeurlthisisfakenotrealahhhh.com/api/v2"

def endpoint(path : String, query = nil)
  uri = URI.parse("#{BASE_URI}#{path}")
  uri.query = URI::Params.encode(query) if query

  uri.to_s
end

def endpoint(regex : Regex)
  Regex.new("#{BASE_URI}#{regex.to_s}")
end
