require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::Me
      include Endpoints::Interface

      def me : API::Result(Types::Me)
        response = get("/users/me")
        API::Result(Types::Me).from(response)
      end
    end
  end
end
