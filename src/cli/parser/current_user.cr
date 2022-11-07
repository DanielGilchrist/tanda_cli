module Tanda::CLI
  class CLI::Parser
    class CurrentUser
      def initialize(@parser : OptionParser, @client : API::Client, @config : Configuration); end

      def parse
        new_id_or_name : String? = nil

        OptionParser.parse do |set_user_parser|
          set_user_parser.on("--set=ID_OR_NAME", "Set the current user") do |id_or_name|
            new_id_or_name = id_or_name
          end
        end

        CLI::Commands::CurrentUser.new(client, config, new_id_or_name).execute
      end

      private getter parser : OptionParser
      private getter client : API::Client
      private getter config : Configuration
    end
  end
end
