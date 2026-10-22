module TandaCLI
  module Models
    struct LeaveBreakdown
      struct Day
        def self.worked(date : Time, hours : Time::Span) : Day
          new(date, hours, nil, holiday: false)
        end

        def self.holiday(date : Time, name : String) : Day
          new(date, Time::Span.zero, name, holiday: true)
        end

        def self.not_working(date : Time) : Day
          new(date, Time::Span.zero, nil, holiday: false)
        end

        private def initialize(@date : Time, @hours : Time::Span, @note : String?, @holiday : Bool) : Nil; end

        getter date : Time
        getter hours : Time::Span
        getter note : String?
        getter? holiday : Bool

        def deducted? : Bool
          !@hours.zero?
        end
      end
    end
  end
end
