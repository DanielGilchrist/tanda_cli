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

DEFAULT_BASE_URI = "https://eu.tanda.co/api/v2"

def endpoint(path : String, query = nil)
  uri = URI.parse("#{DEFAULT_BASE_URI}#{path}")
  uri.query = URI::Params.encode(query) if query

  uri.to_s
end

def endpoint(regex : Regex)
  Regex.new("#{DEFAULT_BASE_URI}#{regex}")
end

def build_stdin(*lines : String) : IO
  IO::Memory.new.tap do |stdin|
    lines.each do |line|
      stdin.puts line
    end

    stdin.rewind
  end
end
