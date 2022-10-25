require "./endpoints/*"

module Tanda::CLI
  module API
    module Endpoints
      include Endpoints::ClockIn
      include Endpoints::Me
      include Endpoints::Shift
    end
  end
end
