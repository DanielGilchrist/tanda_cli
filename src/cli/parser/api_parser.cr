require "./base_parser"

module Tanda::CLI
  class CLI::Parser
    abstract class APIParser < BaseParser(API::Client)
      def client : API::Client
        subject
      end
    end
  end
end
