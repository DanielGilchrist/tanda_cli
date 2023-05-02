require "./endpoints/*"

module Tanda::CLI
  module API
    module Endpoints
      include Endpoints::ClockIn
      include Endpoints::LeaveBalance
      include Endpoints::LeaveRequest
      include Endpoints::Me
      include Endpoints::PersonalDetails
      include Endpoints::Shift
      include Endpoints::User
    end
  end
end
