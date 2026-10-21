require "../helpers/leave"

module TandaCLI
  module Commands
    struct Leave
      @[Kebab::Command(summary: "Show leave taken over the past year")]
      struct Taken
        include Kebab::Parseable
        include Helpers::Leave
        include Options

        def run(context : Context) : Nil
          requests = filter_by_status(fetch_leave(context, Models::LeaveWindow.taken), status)

          display_list(
            context,
            requests,
            "You haven't taken any leave in the past year",
            show_ids: ids?,
            public_holidays: !no_public_holidays?
          )
        end
      end
    end
  end
end
