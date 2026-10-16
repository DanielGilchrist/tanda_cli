module TandaCLI
  module Models
    module BreakPlan
      struct Fixed
        def initialize(@ranges : Array(TimeRange)) : Nil; end

        getter ranges : Array(TimeRange)

        def length : Time::Span
          ranges.sum(&.length)
        end

        def pretty : String
          ranges.map(&.pretty).join(", ")
        end

        def to_s(io : IO) : Nil
          io << ranges.join(' ')
        end
      end
    end
  end
end
