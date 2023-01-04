require "../base"
require "../../types/me/organisation"

module Tanda::CLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        private def build_display
          with_padding("ID", object.id)
          with_padding("Name", object.name)
          with_padding("Country", object.country)
          with_padding("User ID", object.user_id)
          with_padding("Locale", object.locale)
          builder << "\n"
        end
      end
    end
  end
end
