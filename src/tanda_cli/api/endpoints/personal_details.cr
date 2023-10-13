require "../client"

module TandaCLI
  module API
    module Endpoints::PersonalDetails
      def personal_details : API::Result(Types::PersonalDetails)
        response = get("/personal_details")
        API::Result(Types::PersonalDetails).from(response)
      end
    end
  end
end
