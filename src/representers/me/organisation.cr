require "../base"
require "../../types/me/organisation"

module Tanda::CLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        private def build_display(builder : String::Builder)
          {% if flag?(:debug) %}
            with_padding("ID", object.id, builder)
          {% end %}

          with_padding("Name", object.name, builder)
          with_padding("Country", object.country, builder)

          {% if flag?(:debug) %}
            with_padding("User ID", object.user_id, builder)
          {% end %}

          with_padding("Locale", object.locale, builder)
          builder << "\n"
        end
      end
    end
  end
end
