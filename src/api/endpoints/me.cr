require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::Me
      include Endpoints::Interface

      def me : Types::Me::Core
        response = get("/users/me")
        Types::Me::Core.from_json(response.body)
      end
    end
  end
end
