module TandaCLI
  module API
    class Client
      struct Rosters
        def initialize(@request : Request)
        end

        def on_date(date : Time) : API::Result(Types::Roster)
          formatted_date = Utils::Time.iso_date(date)
          @request.get(Types::Roster, "/rosters/on/#{formatted_date}")
        end
      end
    end
  end
end
