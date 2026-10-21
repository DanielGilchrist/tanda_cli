require "colorize"

require "./base"

module TandaCLI
  module Representers
    struct ShiftEdit < Base(Models::ShiftEdit)
      private enum Change
        None
        Changed
        Removed
      end

      private record Row, number : Int32?, label : String, value : String, note : String? = nil, change : Change = Change::None

      private def build_display(builder : Builder) : Nil
        rows = build_rows
        number_width = rows.max_of(&.number.to_s.size)
        label_width = rows.max_of(&.label.size)

        rows.each do |row|
          builder.puts line(row, number_width, label_width)
        end
      end

      private def build_rows : Array(Row)
        targets = @object.targets
        rows = [time_row(number(targets, Models::ShiftEdit::Field::Start), "Start", @object.start, @object.original_start)]

        @object.break_changes.each do |break_change|
          rows << break_row(number(targets, break_change), break_change)
        end

        @object.removed_breaks.each do |shift_break|
          rows << Row.new(nil, "Removed", shift_break.pretty, change: Change::Removed)
        end

        rows << time_row(number(targets, Models::ShiftEdit::Field::Finish), "Finish", @object.finish, @object.original_finish)
      end

      private def number(targets : Array(Models::ShiftEdit::Choice), target : Models::ShiftEdit::Choice) : Int32?
        targets.index(target).try(&.+(1))
      end

      private def time_row(number : Int32?, label : String, time : Time?, original : Time?) : Row
        return Row.new(number, label, pretty(time)) if time == original

        Row.new(number, label, pretty(time), "was #{pretty(original)}", Change::Changed)
      end

      private def break_row(number : Int32?, break_change : Models::ShiftEdit::BreakChange) : Row
        label = "Break #{break_change.number}"
        shift_break = break_change.shift_break
        original = break_change.original
        return Row.new(number, label, shift_break.pretty, "new", Change::Changed) if original.nil?
        return Row.new(number, label, shift_break.pretty) if original == shift_break

        Row.new(number, label, shift_break.pretty, "was #{original.pretty}", Change::Changed)
      end

      private def line(row : Row, number_width : Int32, label_width : Int32) : String
        value =
          case row.change
          in .none?
            row.value
          in .changed?
            row.value.colorize.yellow.to_s
          in .removed?
            row.value.colorize.red.to_s
          end

        number = row.number.to_s.rjust(number_width).colorize.cyan
        note = row.note
        note_string = note ? "  #{note}" : ""

        "  #{number}  #{row.label.ljust(label_width)}  #{value}#{note_string}"
      end

      private def pretty(time : Time?) : String
        time ? Utils::Time.pretty_time(time) : "none"
      end
    end
  end
end
