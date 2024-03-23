require "../client_builder"

module TandaCLI
  module Commands
    class RefetchUsers < Base
      include ClientBuilder

      required_scopes :me

      def setup_
        @name = "refetch_users"
        @summary = @description = "Refetch users from the API and save to config"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Request.ask_which_organisation_and_save!(client, Current.config)
      end
    end
  end
end
