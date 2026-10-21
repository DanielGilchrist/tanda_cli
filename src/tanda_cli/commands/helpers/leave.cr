require "../../representers/leave_list"
require "../../representers/leave_request"

module TandaCLI
  module Commands
    module Helpers
      module Leave
        private def fetch_leave(context : Context, window : Models::LeaveWindow) : Array(API::Types::LeaveRequest)
          context.client.leave_requests
            .list(context.current.user.id, window)
            .or { |error| context.display.error!(error) }
            .sort_by(&.start)
        end

        private def filter_by_status(
          requests : Array(API::Types::LeaveRequest),
          status : API::Types::LeaveRequest::Status::Known?,
        ) : Array(API::Types::LeaveRequest)
          return requests if status.nil?

          requests.select(&.status.==(status))
        end

        private def display_list(
          context : Context,
          requests : Array(API::Types::LeaveRequest),
          empty_message : String,
          show_ids : Bool = false,
          public_holidays : Bool = true,
        ) : Nil
          display = context.display

          hidden = public_holidays ? Array(API::Types::LeaveRequest).new : requests.select(&.public_holiday?)
          visible = public_holidays ? requests : requests.reject(&.public_holiday?)

          return display.info(empty_message) if visible.empty? && hidden.empty?

          Representers::LeaveList.new(visible, show_ids: show_ids, hidden_holidays: hidden).display(display)
        end

        private def display_requests(
          context : Context,
          requests : Array(API::Types::LeaveRequest),
          empty_message : String,
        ) : Nil
          display = context.display
          return display.info(empty_message) if requests.empty?

          last_index = requests.size - 1

          requests.each_with_index do |request, index|
            Representers::LeaveRequest.new(request).display(display)
            display.puts if index != last_index
          end
        end

        private def resolve_window(context : Context, from : Models::ClockInDay?, to : Models::ClockInDay?) : Models::LeaveWindow
          start_of_week = context.config.start_of_week

          case window = Models::LeaveWindow.between(from.try(&.on(start_of_week)), to.try(&.on(start_of_week)))
          in Models::LeaveWindow
            window
          in Error::Base
            context.display.error!(window)
          end
        end
      end
    end
  end
end
