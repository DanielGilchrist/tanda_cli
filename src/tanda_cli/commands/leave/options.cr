require "../../converters/leave_status"

module TandaCLI
  module Commands
    struct Leave
      module Options
        @[Kebab::Option(short: 's', converter: ::TandaCLI::Converters::LeaveStatus, description: "Only show leave with this status (pending/approved/rejected)")]
        getter status : API::Types::LeaveRequest::Status::Known?

        @[Kebab::Option(short: 'i', description: "Show leave request ids")]
        getter? ids : Bool = false

        @[Kebab::Option(long: "no-public-holidays", description: "Hide auto-applied public holidays")]
        getter? no_public_holidays : Bool = false
      end
    end
  end
end
