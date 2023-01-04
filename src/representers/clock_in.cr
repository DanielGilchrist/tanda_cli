require "./base"
require "../types/clock_in"

module Tanda::CLI
  module Representers
    class ClockIn < Base(Types::ClockIn)
      private def build_display
        with_padding("ID", object.id)
        with_padding("Time", object.pretty_date_time)
        with_padding("Type", object.type)
        builder << "\n"
      end
    end
  end
end
