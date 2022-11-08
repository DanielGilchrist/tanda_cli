module Tanda::CLI
  class CLI::Parser
    class CurrentUser
      def initialize(@parser : OptionParser, @config : Configuration); end

      def parse
        list : Bool = false
        new_id_or_name : String? = nil

        OptionParser.parse do |sub_parser|
          sub_parser.on("--list", "List current users") do
            list = true
          end

          sub_parser.on("--set=ID_OR_NAME", "Set the current user") do |id_or_name|
            new_id_or_name = id_or_name
          end
        end

        CLI::Commands::CurrentUser.new(config, new_id_or_name, list).execute
        exit
      end

      private getter parser : OptionParser
      private getter config : Configuration
    end
  end
end
