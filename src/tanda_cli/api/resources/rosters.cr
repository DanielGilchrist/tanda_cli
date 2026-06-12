require "../request"

module TandaCLI
  module API
    module Resources
      struct Rosters
        def initialize(@request : Request); end

        def on(date : Time) : Result(Types::Roster)
          formatted_date = Utils::Time.iso_date(date)
          @request.get(Types::Roster, "/rosters/on/#{formatted_date}")
        end
      end
    end
  end
end
