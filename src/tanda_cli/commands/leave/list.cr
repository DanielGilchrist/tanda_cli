require "../helpers/leave"
require "../../converters/day"

module TandaCLI
  module Commands
    struct Leave
      @[Kebab::Command(summary: "List leave over a date range, defaulting to this year")]
      struct List
        include Kebab::Parseable
        include Helpers::Leave
        include Options

        @[Kebab::Option(short: 'f', converter: ::TandaCLI::Converters::Day, description: "Date to list leave from (\"wednesday\", \"tomorrow\" or YYYY-MM-DD)")]
        getter from : Models::ClockInDay?

        @[Kebab::Option(short: 't', converter: ::TandaCLI::Converters::Day, description: "Date to list leave to (\"wednesday\", \"tomorrow\" or YYYY-MM-DD)")]
        getter to : Models::ClockInDay?

        def run(context : Context) : Nil
          window = resolve_window(context, from, to)
          requests = filter_by_status(fetch_leave(context, window), status)

          display_list(
            context,
            requests,
            "No leave from #{window}",
            show_ids: ids?,
            public_holidays: !no_public_holidays?
          )
        end
      end
    end
  end
end
