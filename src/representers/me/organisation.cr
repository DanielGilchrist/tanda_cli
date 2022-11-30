require "../base"
require "../../types/me/organisation"

module Tanda::CLI
  module Representers
    class Me
      class Organisation < Base(Types::Me::Organisation)
        def display
          display_with_padding("ID", object.id)
          display_with_padding("Name", object.name)
          display_with_padding("Country", object.country)
          display_with_padding("User ID", object.user_id)
          display_with_padding("Locale", object.locale)
          puts "\n"
        end
      end
    end
  end
end
