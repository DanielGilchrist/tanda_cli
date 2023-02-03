module Tanda::CLI
  class CLI::Parser
    abstract class ConfigParser
      def initialize(@parser : OptionParser, @config : Configuration); end

      abstract def parse

      private getter parser : OptionParser
      private getter config : Configuration
    end
  end
end
