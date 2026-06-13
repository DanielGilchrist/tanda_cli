require "../../../kebab/src/kebab"
require "./time_worked/*"

module TandaCLI
  module Commands
    @[Kebab::Command(summary: "See how many hours you've worked")]
    struct TimeWorked
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Today | Week
    end
  end
end
