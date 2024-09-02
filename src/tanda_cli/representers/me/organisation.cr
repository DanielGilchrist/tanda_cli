require "../base"
require "../../types/me/organisation"

module TandaCLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        private def build_display(builder : String::Builder)
          {% if flag?(:debug) %}
            titled_with_padding(debug_str("ID"), @object.id, builder)
            titled_with_padding(debug_str("User ID"), @object.user_id, builder)
          {% end %}

          with_padding("🏷  #{@object.name}", builder)
          with_padding("🌏 #{@object.country}", builder)
          with_padding("📍 #{@object.locale}", builder)
        end
      end
    end
  end
end
