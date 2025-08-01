require "colorize"

require "./base"
require "./shift_break"
require "../types/shift"
require "../types/shift_break"

module TandaCLI
  module Representers
    struct Shift < Base(Types::Shift)
      def initialize(@object : Types::Shift, @expected_finish_time : String? = nil)
      end

      private def build_display(builder : Builder)
        builder << "📅 #{@object.pretty_date}\n"

        pretty_start = @object.pretty_start_time
        pretty_finish = @object.pretty_finish_time || @expected_finish_time
        builder << "🕓 #{pretty_start} - #{pretty_finish}\n" if pretty_start || pretty_finish

        builder << "🚧 #{@object.status}\n"

        build_shift_breaks(builder) if @object.valid_breaks.present?
        build_notes(builder) if @object.notes.present?
      end

      private def build_shift_breaks(builder : Builder)
        builder << "☕️ Breaks:\n".colorize.white.bold
        valid_breaks = @object.valid_breaks
        last_break_index = valid_breaks.size - 1

        valid_breaks.sort_by(&.id).each_with_index do |shift_break, index|
          ShiftBreak.new(shift_break).build(builder)
          builder << '\n' if index != last_break_index
        end
      end

      private def build_notes(builder : Builder)
        builder << "📝 Notes:\n".colorize.white.bold
        @object.notes.each do |note|
          Note.new(note).build(builder)
        end
      end
    end
  end
end
