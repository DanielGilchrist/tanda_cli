require "cling"
require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class RefetchUsers < Cling::Command
      include CLI::ClientBuilder

      def setup : Nil
        @name = "refetch_users"
        @summary = @description = "Refetch users from the API and save to config"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        CLI::Request.ask_which_organisation_and_save!(client, Current.config)
      end
    end
  end
end
