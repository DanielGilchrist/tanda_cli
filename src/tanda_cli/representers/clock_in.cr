require "./base"
require "../types/clock_in"

module TandaCLI
  module Representers
    class ClockIn < Base(Types::ClockIn)
      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          titled_with_padding(debug_str("ID"), @object.id, builder)
        {% end %}

        with_padding("🕔 #{@object.pretty_date_time}", builder)
        with_padding("🤔 #{@object.type}", builder)
      end
    end
  end
end
