require "colorize"

require "./base"
require "../models/measured_break"

module TandaCLI
  module Representers
    struct ShiftBreak < Base(Models::MeasuredBreak)
      private def build_display(builder : Builder) : Nil
        pretty_start = @object.pretty_start_time
        pretty_finish = @object.pretty_finish_time
        with_padding("🕓 #{pretty_start} - #{pretty_finish}", builder) if pretty_start || pretty_finish

        with_padding("⏸️  #{pretty_length}", builder)
        with_padding("💰 #{@object.paid?}", builder)
      end

      private def pretty_length : String
        length = @object.length

        case length
        in Models::BreakLength::Recorded, Models::BreakLength::Running
          pretty_minutes(length.span)
        in Models::BreakLength::Assumed
          "#{pretty_minutes(length.span)}, assuming regular hours break".colorize.yellow.to_s
        in Models::BreakLength::Unknown
          "Unknown length, missing finish time".colorize.yellow.to_s
        end
      end

      private def pretty_minutes(span : Time::Span) : String
        "#{span.total_minutes.to_i} minutes"
      end
    end
  end
end
