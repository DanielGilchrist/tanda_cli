require "./endpoints/*"

module Tanda::CLI
  module API
    module Endpoints
      include Endpoints::Shift
    end
  end
end
