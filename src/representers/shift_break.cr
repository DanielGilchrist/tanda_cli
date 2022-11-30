require "./base"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      def display
        display_with_padding("ID", object.id)
        display_with_padding("Shift ID", object.shift_id)

        pretty_start = object.pretty_start_time
        display_with_padding("Start", pretty_start) if pretty_start

        pretty_finish = object.pretty_finish_time
        display_with_padding("Finish", pretty_finish) if pretty_finish

        display_with_padding("Length", object.length)
        puts "\n"
      end
    end
  end
end
