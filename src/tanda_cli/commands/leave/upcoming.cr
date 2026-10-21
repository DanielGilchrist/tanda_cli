require "../helpers/leave"

module TandaCLI
  module Commands
    struct Leave
      @[Kebab::Command(summary: "Show leave booked between today and a year from now")]
      struct Upcoming
        include Kebab::Parseable
        include Helpers::Leave
        include Options

        def run(context : Context) : Nil
          requests = filter_by_status(fetch_leave(context, Models::LeaveWindow.upcoming), status)

          display_list(
            context,
            requests,
            "You have no upcoming leave",
            show_ids: ids?,
            public_holidays: !no_public_holidays?
          )
        end
      end
    end
  end
end
