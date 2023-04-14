module Tanda::CLI
  class CLI::Parser
    abstract class APIParser
      alias Client = API::Client

      @client : Client? = nil

      def initialize(@parser : OptionParser, @client_builder : -> Client); end

      abstract def parse

      private getter parser : OptionParser

      private def client : Client
        @client ||= @client_builder.call
      end
    end
  end
end
