module TandaCLI
  module Commands
    class RefetchToken < Base
      def setup_
        @name = "refetch_token"
        @summary = @description = "Refetch token for the current environment"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        config = context.config
        config.reset_environment!
        API::Auth.fetch_new_token!(config)

        Request.ask_which_organisation_and_save!(client, config)
      end
    end
  end
end
