require "../client_builder"

module TandaCLI
  module Commands
    class PersonalDetails < Base
      include ClientBuilder

      def setup_
        @name = "personal_details"
        @summary = @description = "Get your personal details"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        personal_details = client.personal_details.or(&.display!)
        Representers::PersonalDetails.new(personal_details).display
      end
    end
  end
end
