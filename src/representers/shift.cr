require "./base"
require "./shift_break"
require "../types/shift"
require "../types/shift_break"

module Tanda::CLI
  module Representers
    class Shift < Base(Types::Shift)
      def display
        puts "ID: #{object.id}"
        puts "User ID: #{object.user_id}"
        puts "Date: #{object.pretty_date}"

        pretty_start = object.pretty_start_time
        puts "Start: #{pretty_start}" if pretty_start

        pretty_finish = object.pretty_finish_time
        puts "Finish: #{pretty_finish}" if pretty_finish

        puts "Status: #{object.status}"

        display_shift_breaks if !object.breaks.empty?

        puts "\n"
      end

      private def display_shift_breaks
        puts "Breaks:"
        object.breaks.sort_by(&.id).each do |shift_break|
          ShiftBreak.new(shift_break).display
        end
      end
    end
  end
end
