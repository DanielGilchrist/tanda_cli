require "colorize"

require "./base"
require "./shift_break"
require "../types/shift"
require "../types/shift_break"

module TandaCLI
  module Representers
    struct Shift < Base(Types::Shift)
      private def build_display(builder : Builder)
        builder << "📅 #{@object.pretty_date}\n"

        pretty_start = @object.pretty_start_time
        pretty_finish = @object.pretty_finish_time
        builder << "🕓 #{pretty_start} - #{pretty_finish}\n" if pretty_start || pretty_finish

        builder << "🚧 #{@object.status}\n"

        build_shift_breaks(builder) if @object.valid_breaks.present?
        build_notes(builder) if @object.notes.present?
      end

      private def build_shift_breaks(builder : Builder)
        builder << "☕️ Breaks:\n".colorize.white.bold
        @object.valid_breaks.sort_by(&.id).each do |shift_break|
          ShiftBreak.new(shift_break).build(builder)
          builder << '\n'
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
