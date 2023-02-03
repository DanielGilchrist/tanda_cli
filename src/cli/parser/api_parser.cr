module Tanda::CLI
  class CLI::Parser
    abstract class APIParser
      @client : API::Client? = nil

      def initialize(@parser : OptionParser, @client_builder : -> API::Client); end

      abstract def parse

      private def client : API::Client
        @client ||= @client_builder.call
      end

      private getter parser : OptionParser
    end
  end
end
