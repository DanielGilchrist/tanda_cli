require "kebab"
require "./leave/options"
require "./leave/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "View and request your leave")]
    struct Leave
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : List | Upcoming | Taken | Show | Request
    end
  end
end
