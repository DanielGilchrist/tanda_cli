require "./base"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      private def build_display
        with_padding("ID", object.id)
        with_padding("Shift ID", object.shift_id)

        pretty_start = object.pretty_start_time
        with_padding("Start", pretty_start) if pretty_start

        pretty_finish = object.pretty_finish_time
        with_padding("Finish", pretty_finish) if pretty_finish

        with_padding("Length", object.length)
        builder << "\n"
      end
    end
  end
end
