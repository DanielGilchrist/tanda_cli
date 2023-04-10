require "./base"
require "./shift_break"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class Shift < Base(Types::Shift)
      private def build_display(builder : String::Builder)
        {% if flag?(:debug) %}
          builder << "ID: #{object.id}\n"
          builder << "User ID: #{object.user_id}\n"
        {% end %}

        builder << "Date: #{object.pretty_date}\n"

        pretty_start = object.pretty_start_time
        builder << "Start: #{pretty_start}\n" if pretty_start

        pretty_finish = object.pretty_finish_time
        builder << "Finish: #{pretty_finish}\n" if pretty_finish

        builder << "Status: #{object.status}\n"

        display_shift_breaks(builder) if !object.valid_breaks.empty?

        builder << "\n"
      end

      private def display_shift_breaks(builder : String::Builder)
        builder << "Breaks:\n"
        object.valid_breaks.sort_by(&.id).each do |shift_break|
          builder << ShiftBreak.new(shift_break).build
          builder << "\n"
        end
      end
    end
  end
end
