module TandaCLI
  module Models
    module BreakPlan
      struct None
        def length : Time::Span
          Time::Span.zero
        end

        def pretty : String
          "—"
        end

        def to_s(io : IO) : Nil
          io << "none"
        end
      end
    end
  end
end
