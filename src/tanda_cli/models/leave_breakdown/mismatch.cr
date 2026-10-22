module TandaCLI
  module Models
    struct LeaveBreakdown
      # Tanda's hours and the hours your regular schedule accounts for disagree
      struct Mismatch
        def initialize(@charged : Time::Span, @scheduled : Time::Span) : Nil; end

        getter charged : Time::Span
        getter scheduled : Time::Span

        def difference : Time::Span
          (@charged - @scheduled).abs
        end
      end
    end
  end
end
