require "kebab"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "personal_details", summary: "Get your personal details")]
    struct PersonalDetails
      include Kebab::Parseable

      def run(context : Context) : Nil
        display = context.display
        personal_details = context.client.personal_details.fetch.or { |error| display.error!(error) }
        Representers::PersonalDetails.new(personal_details).display(display)
      end
    end
  end
end
