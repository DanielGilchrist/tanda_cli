require "../helpers/leave"
require "../../models/leave_lookup"

module TandaCLI
  module Commands
    struct Leave
      @[Kebab::Command(summary: "Show a single leave request by id, or the leave on a given day")]
      struct Show
        include Kebab::Parseable
        include Helpers::Leave

        @[Kebab::Argument(description: "A leave request id, or a day (\"wednesday\", \"tomorrow\" or YYYY-MM-DD)")]
        getter id_or_date : String

        def run(context : Context) : Nil
          display = context.display

          case lookup = Models::LeaveLookup.parse(id_or_date)
          in Models::LeaveLookup::Id
            show_by_id(context, lookup.value)
          in Models::LeaveLookup::Date
            show_on_date(context, lookup.on(context.config.start_of_week))
          in Error::Base
            display.error!(lookup)
          end
        end

        private def show_by_id(context : Context, id : Int32) : Nil
          requests = context.client.leave_requests
            .list(ids: [id])
            .or { |error| context.display.error!(error) }

          display_requests(context, requests, "No leave request found with id #{id}")
        end

        private def show_on_date(context : Context, date : Time) : Nil
          window = Models::LeaveWindow.on(date)
          requests = fetch_leave(context, window)

          display_requests(context, requests, "No leave on #{Utils::Time.pretty_date(date)}")
        end
      end
    end
  end
end
