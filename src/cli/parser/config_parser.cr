require "../../configuration"

module Tanda::CLI
  class CLI::Parser
    abstract class ConfigParser
      @config : Configuration? = nil

      def initialize(@parser : OptionParser); end

      abstract def parse

      private getter parser : OptionParser

      private def config : Configuration
        @config ||= Current.config
      end
    end
  end
end
