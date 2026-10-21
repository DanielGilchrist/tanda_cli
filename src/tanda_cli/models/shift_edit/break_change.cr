require "./break"

module TandaCLI
  module Models
    class ShiftEdit
      record BreakChange, shift_break : Break, original : Break?, index : Int32, number : Int32 do
        def changed? : Bool
          shift_break != original
        end

        def start_changed? : Bool
          shift_break.start != original.try(&.start)
        end

        def finish_changed? : Bool
          shift_break.finish != original.try(&.finish)
        end
      end
    end
  end
end
