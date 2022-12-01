require "./base"
require "../types/clock_in"

module Tanda::CLI
  module Representers
    class ClockIn < Base(Types::ClockIn)
      def display
        display_with_padding("ID", object.id)
        display_with_padding("Time", object.pretty_date_time)
        display_with_padding("Type", object.type)
        puts "\n"
      end
    end
  end
end
