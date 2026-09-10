require "colorize"

require "./base"
require "./shift_break"
require "../models/worked_shift"

module TandaCLI
  module Representers
    struct Shift < Base(Models::WorkedShift)
      def initialize(
        @object : Models::WorkedShift,
        @breaks : Models::ShiftBreaks,
        @expected_start_time : Time? = nil,
        @expected_finish_time : Time? = nil,
        @expected_break_length : Time::Span? = nil,
      ) : Nil
      end

      private def build_display(builder : Builder) : Nil
        builder << "📅 #{@object.pretty_date}\n"

        pretty_expected_start_time = @expected_start_time.try { |time| Utils::Time.pretty_time(time) }
        pretty_expected_finish_time = @expected_finish_time.try { |time| Utils::Time.pretty_time(time) }
        pretty_start = @object.pretty_start_time || pretty_expected_start_time
        pretty_start = pretty_start.colorize.yellow if pretty_start && pretty_expected_start_time
        pretty_finish = @object.pretty_finish_time || pretty_expected_finish_time
        pretty_finish = pretty_finish.colorize.yellow if pretty_finish && pretty_expected_finish_time
        builder << "🕓 #{pretty_start} - #{pretty_finish}\n" if pretty_start || pretty_finish

        builder << "🚧 #{@object.status}\n"

        build_shift_breaks(builder) if @breaks.measured.present? || @expected_break_length
        build_notes(builder) if @object.notes.present?
      end

      private def build_shift_breaks(builder : Builder) : Nil
        expected_break_length = @expected_break_length

        if (breaks = @breaks.measured).present?
          builder << "☕️ Breaks:\n".colorize.white.bold
          last_break_index = breaks.size - 1

          breaks.sort_by(&.id).each_with_index do |shift_break, index|
            ShiftBreak.new(shift_break).build(builder)
            builder << '\n' if index != last_break_index
          end
        elsif expected_break_length && !expected_break_length.zero?
          builder << "☕️ #{expected_break_length.total_minutes.to_i} minutes\n".colorize.yellow
        end
      end

      private def build_notes(builder : Builder) : Nil
        builder << "📝 Notes:\n".colorize.white.bold
        @object.notes.each do |note|
          Note.new(note).build(builder)
        end
      end
    end
  end
end
