require "json"

module TandaCLI
  module API
    module Types
      class ShiftUpdate
        include JSON::Serializable

        @finish : Int64?
        @breaks : Array(Break)?

        def initialize; end

        def finish(time : Time) : Nil
          @finish = time.to_unix
        end

        def add_break(start : Time, finish : Time?, paid : Bool) : Nil
          (@breaks ||= [] of Break) << Break.new(start, finish, paid)
        end
      end
    end
  end
end
