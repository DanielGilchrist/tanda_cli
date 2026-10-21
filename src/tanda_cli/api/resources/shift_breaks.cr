require "../request"
require "../types/shift_break_update"

module TandaCLI
  module API
    module Resources
      struct ShiftBreaks
        def initialize(@request : Request) : Nil; end

        def create(shift_id : Int32, & : Types::ShiftBreakUpdate ->) : Result(Nil)
          update = Types::ShiftBreakUpdate.new
          yield update

          @request.post(Nil, "/shifts/#{shift_id}/breaks", body: update)
        end

        def update(shift_id : Int32, break_id : Int32, & : Types::ShiftBreakUpdate ->) : Result(Nil)
          update = Types::ShiftBreakUpdate.new
          yield update

          @request.put(Nil, "/shifts/#{shift_id}/breaks/#{break_id}", body: update)
        end
      end
    end
  end
end
