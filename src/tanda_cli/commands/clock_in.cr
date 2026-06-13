require "../../../kebab/src/kebab"
require "./clock_in/*"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "clockin", summary: "Clock in/out")]
    struct ClockIn
      include Kebab::Parseable

      @[Kebab::Subcommand]
      getter command : Start | Finish | Break | Backfill | Photo | Status | Display
    end
  end
end
