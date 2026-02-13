require "./base"
require "../types/clock_in"

module TandaCLI
  module Representers
    struct ClockIn < Base(Types::ClockIn)
      private def build_display(builder : Builder)
        with_padding("🕔 #{@object.pretty_date_time}", builder)
        with_padding("🤔 #{@object.type}", builder)
      end
    end
  end
end
