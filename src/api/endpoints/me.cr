require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::Me
      include Endpoints::Interface

      def me : API::Result(Types::Me::Core)
        response = get("/users/me")
        API::Result(Types::Me::Core).from(response)
      end
    end
  end
end
