module TandaCLI
  module API
    class Client
      struct PersonalDetails
        def initialize(@request : Request)
        end

        def get : API::Result(Types::PersonalDetails)
          @request.get(Types::PersonalDetails, "/personal_details")
        end
      end
    end
  end
end
