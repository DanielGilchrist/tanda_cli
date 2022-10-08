require "./base"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      def display
        display_with_padding("ID", object.id)
        display_with_padding("Shift ID", object.shift_id)
        display_with_padding("Start", object.start)
        display_with_padding("Finish", object.finish)
        display_with_padding("Length", object.length)
        puts "\n"
      end
    end
  end
end
