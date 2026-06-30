require "json"

require "../shift_update"

module TandaCLI
  module API
    module Types
      struct ShiftUpdate::Break
        include JSON::Serializable

        getter start : Int64
        getter finish : Int64?
        getter? paid : Bool
        getter length : Int32

        def initialize(start : Time, finish : Time?, @paid : Bool)
          @start = start.to_unix
          @finish = finish.try(&.to_unix)
          @length = finish ? (finish - start).total_minutes.to_i : 0
        end
      end
    end
  end
end
