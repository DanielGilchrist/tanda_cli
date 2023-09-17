require "cling"
require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class RefetchToken < Cling::Command
      include CLI::ClientBuilder

      def setup : Nil
        @name = "refetch_token"
        @description = "Refetch token for the current environment"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        config = Current.config
        config.reset_environment!
        API::Auth.fetch_new_token!

        client = create_client_from_config
        CLI::Request.ask_which_organisation_and_save!(client, config)
      end
    end
  end
end
