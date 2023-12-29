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
    CommandOutput.clear
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

  CommandOutput.format
end

module CommandOutput
  extend self

  delegate :clear, :format, :puts, to: instance

  private def instance
    @@_instance ||= Instance.new
  end

  private class Instance
    HEADER_REGEX = /Success: Selected organisation \"[^\"]+\"\nSuccess: Organisations saved to config\n/

    def initialize(@io : IO::Memory = IO::Memory.new)
    end

    delegate :clear, :puts, to: @io

    def format
      @io.to_s.gsub(HEADER_REGEX, "")
    end
  end
end

module TandaCLI
  module Utils
    module Display
      extend self

      def print(*objects)
        CommandOutput.puts(*objects)
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
      new.tap(&.overwrite!(DEFAULT_SITE_PREFIX, DEFAULT_EMAIL, DEFAULT_ACCESS_TOKEN))
    end

    def save!
      return
    end
  end
end
#
# WARNING
#
