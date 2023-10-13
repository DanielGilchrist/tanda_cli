require "./endpoints/*"

module TandaCLI
  module API
    module Endpoints
      include Endpoints::ClockIn
      include Endpoints::LeaveBalance
      include Endpoints::LeaveRequest
      include Endpoints::Me
      include Endpoints::PersonalDetails
      include Endpoints::Roster
      include Endpoints::Shift
    end
  end
end
