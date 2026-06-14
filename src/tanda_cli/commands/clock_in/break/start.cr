require "../../helpers/clock_in"
require "../options"

module TandaCLI
  module Commands
    struct ClockIn
      struct Break
        @[Kebab::Command(summary: "Start break")]
        struct Start
          include Kebab::Parseable
          include ClockIn::Options
          include Helpers::ClockIn

          def run(context : Context) : Nil
            execute_clock_in(context, :break_start)
          end
        end
      end
    end
  end
end
