require "./base"
require "../api/types/clock_in"

module TandaCLI
  module Representers
    struct ClockIn < Base(API::Types::ClockIn)
      private def build_display(builder : Builder) : Nil
        with_padding("🕔 #{@object.pretty_date_time}", builder)
        with_padding("🤔 #{@object.type}", builder)
      end
    end
  end
end
