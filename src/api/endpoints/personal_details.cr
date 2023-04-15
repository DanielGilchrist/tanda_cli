require "./interface.cr"
require "../client"

module Tanda::CLI
  module API
    module Endpoints::PersonalDetails
      include Endpoints::Interface

      def personal_details : API::Result(Types::PersonalDetails)
        response = get("/personal_details")
        API::Result(Types::PersonalDetails).from(response)
      end
    end
  end
end
