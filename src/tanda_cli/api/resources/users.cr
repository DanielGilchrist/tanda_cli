require "../request"

module TandaCLI
  module API
    module Resources
      struct Users
        def initialize(@request : Request); end

        def me : Result(Types::Me)
          @request.get(Types::Me, "/users/me")
        end
      end
    end
  end
end
