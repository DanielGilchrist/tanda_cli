require "./endpoints/*"

module Tanda::CLI
  module API
    module Endpoints
      include Endpoints::Me
      include Endpoints::Shift
    end
  end
end
