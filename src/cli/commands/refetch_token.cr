require "admiral"
require "../client_builder"

module Tanda::CLI
  class CLI::Commmands
    class RefetchToken < Admiral::Command
      include CLI::ClientBuilder

      def run
        config = Current.config
        config.reset_environment!
        API::Auth.fetch_new_token!

        client = create_client_from_config
        CLI::Request.ask_which_organisation_and_save!(client, config)
      end
    end
  end
end
