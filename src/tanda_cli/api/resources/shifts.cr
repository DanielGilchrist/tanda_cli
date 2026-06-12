require "../request"

module TandaCLI
  module API
    module Resources
      struct Shifts
        def initialize(@request : Request); end

        def list(user_id : Int32, date : Time, show_notes : Bool = false) : Result(Array(Types::Shift))
          list(user_id, date, date, show_notes: show_notes)
        end

        def list(user_id : Int32, start_date : Time, finish_date : Time, show_notes : Bool = false) : Result(Array(Types::Shift))
          start_string, finish_string = {
            start_date,
            finish_date,
          }
            .map(&.to_s("%Y-%m-%d"))

          @request.get(Array(Types::Shift), "/shifts", query: {
            "user_ids"   => user_id.to_s,
            "from"       => start_string,
            "to"         => finish_string,
            "show_notes" => show_notes.to_s,
            "cache_key"  => cache_key,
          })
        end

        private def cache_key : String
          Time::Format.new("%Y-%m-%d-%H-%M").format(Time.local)
        end
      end
    end
  end
end
