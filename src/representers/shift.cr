require "colorize"

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

        builder << "📅 #{object.pretty_date}\n"

        pretty_start = object.pretty_start_time
        pretty_finish = object.pretty_finish_time
        builder << "🕓 #{pretty_start} - #{pretty_finish}\n" if pretty_start || pretty_finish

        builder << "🚧 #{object.status}\n"

        build_shift_breaks(builder) if !object.valid_breaks.empty?
      end

      private def build_shift_breaks(builder : String::Builder)
        builder << "Breaks:\n".colorize.bold
        object.valid_breaks.sort_by(&.id).each do |shift_break|
          builder << ShiftBreak.new(shift_break).build
        end
      end
    end
  end
end
