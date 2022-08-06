require "./base"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class Shift < Base(Types::Shift)
      def display
        puts "ID: #{object.id}"
        puts "User ID: #{object.user_id}"
        puts "Start: #{object.start}"
        puts "Finish: #{object.finish}"
        puts "Status: #{object.status}"

        display_shift_breaks

        puts "\n"
      end

      private def display_shift_breaks
        puts "Breaks:"
        object.breaks.each do |shift_break|
          display_shift_break(shift_break)
        end
      end

      private def display_shift_break(shift_break : Types::ShiftBreak)
        display_with_padding("ID", shift_break.id)
        display_with_padding("Shift ID", shift_break.shift_id)
        display_with_padding("Start", shift_break.start)
        display_with_padding("Finish", shift_break.finish)
        display_with_padding("Length", shift_break.length)
      end
    end
  end
end
