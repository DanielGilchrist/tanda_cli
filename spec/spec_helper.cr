require "colorize"

# Makes asserting on output much easier
Colorize.enabled = false

require "spectator"
require "webmock"

require "../src/tanda_cli"
require "../src/tanda_cli/utils/display"
require "../src/tanda_cli/configuration"

Spectator.configure do |config|
  config.randomize = true
  config.before_each do
    TandaCLI::Current.reset!
    TandaCLI::Utils::Display.reset_output!
    WebMock.reset
  end
end

#
# WARNING
#
# absolutely none of this is good practice.
# if you happen to come across this and think it might be a good idea to do something similar,
# please instead consider using interfaces and dependency injection with mock objects.
#
def with_command_output(&)
  begin
    yield
  rescue Spectator::SystemExit
  end

  format_command_output(TandaCLI::Utils::Display.output)
end

def format_command_output(output : IO) : String
  output
    .to_s
    .gsub(/Success: Selected organisation \"[^\"]+\"\nSuccess: Organisations saved to config\n/, "")
end

module TandaCLI
  module Utils
    module Display
      extend self

      @@io = IO::Memory.new

      def print(*objects)
        @@io.puts(*objects)
      end

      def output
        @@io
      end

      def reset_output!
        @@io = IO::Memory.new
      end

      def print_output
        puts @@io
      end
    end
  end
end

module TandaCLI
  class Configuration
    DEFAULT_SITE_PREFIX  = "eu"
    DEFAULT_EMAIL        = "testemail@email.com"
    ACCESS_TOKEN_BODY    = %({ "access_token": "test_access_token", "token_type": "bearer", "scope": "me", "created_at": #{Time.utc.to_unix.to_i32} })
    DEFAULT_ACCESS_TOKEN = TandaCLI::Types::AccessToken.from_json(ACCESS_TOKEN_BODY)

    def self.init : Configuration
      new.tap do |config|
        config.overwrite!(DEFAULT_SITE_PREFIX, DEFAULT_EMAIL, DEFAULT_ACCESS_TOKEN)
      end
    end

    def save!
      return
    end
  end
end
#
# WARNING
#
