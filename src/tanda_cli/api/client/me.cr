module TandaCLI
  module API
    class Client
      struct Me
        def initialize(@request : Request)
        end

        def get : API::Result(Types::Me)
          @request.get(Types::Me, "/users/me")
        end
      end
    end
  end
end
