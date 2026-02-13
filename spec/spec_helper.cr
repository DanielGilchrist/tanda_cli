require "spec"
require "colorize"
require "webmock"

# Makes asserting on output much easier
Colorize.enabled = false

require "../src/tanda_cli"
require "./support/travel_to_hack"
require "./support/configuration/fixture_file"

Spec.before_each do
  WebMock.reset
end

DEFAULT_BASE_URI = "https://eu.tanda.co/api/v2"

def run(
  args : Array(String),
  stdin : IO = IO::Memory.new,
  config_fixture : Configuration::FixtureFile::Fixture = :default,
) : TandaCLI::Context
  context = TandaCLI.main(
    args,
    stdout: IO::Memory.new,
    stderr: IO::Memory.new,
    stdin: stdin,
    config_file: Configuration::FixtureFile.load(config_fixture)
  )

  {% if flag?(:print_output) %}
    print_output(context)
  {% end %}

  context
end

def print_output(context : TandaCLI::Context)
  stdout = context.stdout.to_s
  stderr = context.stderr.to_s

  unless stdout.empty?
    STDERR.puts "\n--- STDOUT ---"
    STDERR.puts stdout
    STDERR.puts "--- END STDOUT ---"
  end

  unless stderr.empty?
    STDERR.puts "\n--- STDERR ---"
    STDERR.puts stderr
    STDERR.puts "--- END STDERR ---"
  end
end

def build_stdin(*lines : String) : IO
  IO::Memory.new.tap do |stdin|
    lines.each do |line|
      stdin.puts line
    end

    stdin.rewind
  end
end

def endpoint(path : String, query = nil)
  uri = URI.parse("#{DEFAULT_BASE_URI}#{path}")
  uri.query = URI::Params.encode(query) if query

  uri.to_s
end

def endpoint(regex : Regex)
  Regex.new("#{DEFAULT_BASE_URI}#{regex}")
end
