require "./base_parser"

module Tanda::CLI
  class CLI::Parser
    abstract class ConfigParser < BaseParser(Configuration)
      def config : Configuration
        subject
      end
    end
  end
end
