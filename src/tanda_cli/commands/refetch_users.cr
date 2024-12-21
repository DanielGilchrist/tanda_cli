module TandaCLI
  module Commands
    class RefetchUsers < Base
      def setup_
        @name = "refetch_users"
        @summary = @description = "Refetch users from the API and save to config"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Request.ask_which_organisation_and_save!(client, config)
      end
    end
  end
end
