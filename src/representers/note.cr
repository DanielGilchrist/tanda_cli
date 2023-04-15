require "./base"
require "../types/note"

module Tanda::CLI
  module Representers
    class Note < Base(Types::Note)
      private def build_display(builder : String::Builder)
        with_padding("✍️  #{object.author}", builder)
        with_padding("💬 #{object.body}", builder)
        with_padding("⏳ #{object.pretty_date_time}", builder)
      end
    end
  end
end
