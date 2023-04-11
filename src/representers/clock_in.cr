require "./base"
require "../types/clock_in"

module Tanda::CLI
  module Representers
    class ClockIn < Base(Types::ClockIn)
      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          titled_with_padding("ID", object.id, builder)
        {% end %}

        titled_with_padding("Time", object.pretty_date_time, builder)
        titled_with_padding("Type", object.type, builder)
      end
    end
  end
end
