require "./base"
require "../types/clock_in"

module Tanda::CLI
  module Representers
    class ClockIn < Base(Types::ClockIn)
      private def build_display(builder : String::Builder)
        with_padding("ID", object.id, builder)
        with_padding("Time", object.pretty_date_time, builder)
        with_padding("Type", object.type, builder)
        builder << "\n"
      end
    end
  end
end
