module TandaCLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        private def build_display(builder : String::Builder)
          with_padding("🏷 #{@object.name}", builder)
          with_padding("🌏 #{@object.country}", builder)
          with_padding("📍 #{@object.locale}", builder)
        end
      end
    end
  end
end
