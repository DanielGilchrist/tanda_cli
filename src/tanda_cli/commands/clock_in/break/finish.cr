require "../../helpers/clock_in"
require "../options"

module TandaCLI
  module Commands
    struct ClockIn
      struct Break
        @[Kebab::Command(name: "finish", summary: "Finish break")]
        struct Finish
          include Kebab::Serialisable
          include ClockIn::Options
          include Helpers::ClockIn

          def run(context : Context) : Nil
            execute_clock_in(context, :break_finish)
          end
        end
      end
    end
  end
end
