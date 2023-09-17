require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class PersonalDetails < Base
      include CLI::ClientBuilder

      def on_setup
        @name = "personal_details"
        @summary = @description = "Get your personal details"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        personal_details = client.personal_details.or(&.display!)
        Representers::PersonalDetails.new(personal_details).display
      end
    end
  end
end
