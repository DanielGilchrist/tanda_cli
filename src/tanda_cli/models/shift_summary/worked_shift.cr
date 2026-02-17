module TandaCLI
  module Models
    struct ShiftSummary
      struct WorkedShift
        def self.from(shift : Types::Shift, treat_paid_breaks_as_unpaid : Bool = false) : WorkedShift
          time_worked = shift.time_worked(treat_paid_breaks_as_unpaid)
          worked_so_far = shift.worked_so_far(treat_paid_breaks_as_unpaid)

          new(
            shift,
            time_worked: time_worked || worked_so_far,
            ongoing: time_worked.nil? && !worked_so_far.nil?,
          )
        end

        def initialize(
          @shift : Types::Shift,
          time_worked : Time::Span?,
          @ongoing : Bool,
        )
          @time_worked = time_worked || Time::Span.zero
        end

        getter shift : Types::Shift
        getter time_worked : Time::Span
        getter? ongoing : Bool

        delegate :ongoing?, to: shift
      end
    end
  end
end
