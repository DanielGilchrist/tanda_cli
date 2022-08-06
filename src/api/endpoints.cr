require "./endpoints/*"

module Tanda::CLI
  module API
    module Endpoints
      include Endpoints::Leave
      include Endpoints::Shift
    end
  end
end
