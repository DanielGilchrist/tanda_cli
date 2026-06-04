require "../client"

module TandaCLI
  module API
    module Endpoints::PersonalDetails
      def personal_details : API::Result(API::Types::PersonalDetails)
        response = get("/personal_details")
        API::Result(API::Types::PersonalDetails).from(response)
      end
    end
  end
end
