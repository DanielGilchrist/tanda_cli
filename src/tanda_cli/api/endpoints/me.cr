require "../client"

module TandaCLI
  module API
    module Endpoints::Me
      def me : API::Result(API::Types::Me)
        response = get("/users/me")
        API::Result(API::Types::Me).from(response)
      end
    end
  end
end
