module TandaCLI
  module Representers
    class ShiftBreak < Base(Types::ShiftBreak)
      private def build_display(builder : String::Builder)
        pretty_start = @object.pretty_start_time
        pretty_finish = @object.pretty_finish_time
        with_padding("🕓 #{pretty_start} - #{pretty_finish}", builder) if pretty_start || pretty_finish

        with_padding("⏸️  #{@object.pretty_ongoing_length}", builder)
        with_padding("💰 #{@object.paid?}", builder)
      end
    end
  end
end
