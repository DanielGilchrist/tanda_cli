require "kebab"
require "./auth/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "Manage authentication")]
    struct Auth
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Login | Logout | Status
    end
  end
end
