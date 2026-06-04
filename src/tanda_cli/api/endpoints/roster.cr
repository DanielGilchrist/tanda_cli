require "../client"

module TandaCLI
  module API
    module Endpoints::Roster
      def roster_on_date(date : Time) : API::Result(API::Types::Roster)
        formatted_date = Utils::Time.iso_date(date)
        response = get("/rosters/on/#{formatted_date}")

        API::Result(API::Types::Roster).from(response)
      end
    end
  end
end
