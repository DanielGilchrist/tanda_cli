module TandaCLI
  module Commands
    class PersonalDetails < Base
      required_scopes :personal

      def setup_
        @name = "personal_details"
        @summary = @description = "Get your personal details"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        personal_details = client.personal_details.or { |error| display.error!(error) }
        Representers::PersonalDetails.new(personal_details).display(stdout)
      end
    end
  end
end
