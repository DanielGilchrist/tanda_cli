require "../helpers/clock_in"
require "./options"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Clock out")]
      struct Finish
        include Kebab::Parseable
        include Options
        include Helpers::ClockIn

        def run(context : Context) : Nil
          execute_clock_in(context, :finish)
        end
      end
    end
  end
end
