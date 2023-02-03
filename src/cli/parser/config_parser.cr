module Tanda::CLI
  class CLI::Parser
    abstract class ConfigParser
      @config : Configuration? = nil

      def initialize(@parser : OptionParser, @config_builder : -> Configuration); end

      abstract def parse

      private getter parser : OptionParser

      private def config : Configuration
        @config ||= @config_builder.call
      end
    end
  end
end
