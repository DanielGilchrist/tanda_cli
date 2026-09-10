require "../request"

module TandaCLI
  module API
    module Resources
      struct PersonalDetails
        def initialize(@request : Request) : Nil; end

        def fetch : Result(Types::PersonalDetails)
          @request.get(Types::PersonalDetails, "/personal_details")
        end
      end
    end
  end
end
