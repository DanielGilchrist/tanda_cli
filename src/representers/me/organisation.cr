require "../base"
require "../../types/me/organisation"

module Tanda::CLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        private def build_display(builder : String::Builder)
          {% if flag?(:debug) %}
            titled_with_padding("ID", object.id, builder)
            titled_with_padding("User ID", object.user_id, builder)
          {% end %}

          titled_with_padding("Name", object.name, builder)
          titled_with_padding("Country", object.country, builder)
          titled_with_padding("Locale", object.locale, builder)
        end
      end
    end
  end
end
