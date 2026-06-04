require "../base"
require "../../api/types/me/organisation"

module TandaCLI
  module Representers
    struct Me
      struct Organisation < Base(API::Types::Me::Organisation)
        private def build_display(builder : Builder)
          with_padding("🏷 #{@object.name}", builder)
          with_padding("🌏 #{@object.country}", builder)
          with_padding("📍 #{@object.locale}", builder)
        end
      end
    end
  end
end
