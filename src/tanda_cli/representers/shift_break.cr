require "./base"
require "../types/shift"
require "../types/shift_break"

module TandaCLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          titled_with_padding("ID", @object.id, builder)
          titled_with_padding("Shift ID", @object.shift_id, builder)
        {% end %}

        pretty_start = @object.pretty_start_time
        pretty_finish = @object.pretty_finish_time
        with_padding("🕓 #{pretty_start} - #{pretty_finish}", builder) if pretty_start || pretty_finish

        with_padding("⏸️  #{@object.pretty_ongoing_length}", builder)
        with_padding("💰 #{@object.paid?}", builder)
      end
    end
  end
end
