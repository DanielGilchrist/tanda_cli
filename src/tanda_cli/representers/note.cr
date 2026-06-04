require "./base"
require "../api/types/note"

module TandaCLI
  module Representers
    struct Note < Base(API::Types::Note)
      private def build_display(builder : Builder)
        with_padding("✍️  #{@object.author}", builder)
        with_padding("💬 #{@object.body}", builder)
        with_padding("⏳ #{@object.pretty_date_time}", builder)
      end
    end
  end
end
