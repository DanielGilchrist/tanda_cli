require "./base"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          with_padding("ID", object.id, builder)
          with_padding("Shift ID", object.shift_id, builder)
        {% end %}

        pretty_start = object.pretty_start_time
        with_padding("Start", pretty_start, builder) if pretty_start

        pretty_finish = object.pretty_finish_time
        with_padding("Finish", pretty_finish, builder) if pretty_finish

        with_padding("Length", object.pretty_ongoing_length, builder)
        with_padding("Paid", object.paid?, builder)
      end
    end
  end
end
