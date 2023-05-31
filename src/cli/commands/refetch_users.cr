require "admiral"
require "../client_builder"

module Tanda::CLI
  class CLI::Commmands
    class RefetchUsers < Admiral::Command
      include CLI::ClientBuilder

      def run
        CLI::Request.ask_which_organisation_and_save!(client, Current.config)
      end
    end
  end
end
