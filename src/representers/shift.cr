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
        puts "Start: #{object.start}"
        puts "Finish: #{object.finish}"
        puts "Status: #{object.status}"

        display_shift_breaks

        puts "\n"
      end

      private def display_shift_breaks
        puts "Breaks:"
        object.breaks.sort_by(&.id).each do |shift|
          ShiftBreak.new(shift).display
        end
      end
    end
  end
end
