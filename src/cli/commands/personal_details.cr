require "admiral"
require "../client_builder"

module Tanda::CLI
  class CLI::Commmands
    class PersonalDetails < Admiral::Command
      include CLI::ClientBuilder

      def run
        personal_details = client.personal_details.or(&.display!)
        Representers::PersonalDetails.new(personal_details).display
      end
    end
  end
end
