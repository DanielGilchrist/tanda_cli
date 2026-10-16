module TandaCLI
  module Models
    module BreakPlan
      struct Automatic
        def initialize(@length : Time::Span) : Nil; end

        getter length : Time::Span

        def pretty : String
          "#{length.total_minutes.to_i}min"
        end

        def to_s(io : IO) : Nil
          io << length.total_minutes.to_i << 'm'
        end
      end
    end
  end
end
