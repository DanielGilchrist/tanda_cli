require "../ext/kebab"
require "./current_user/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "View the current user, list available users or set the current user")]
    struct CurrentUser
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Display | List | Set
    end
  end
end
