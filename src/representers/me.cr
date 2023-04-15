require "./base"
require "../types/me/**"

require "colorize"

module Tanda::CLI
  module Representers
    class Me < Base(Types::Me)
      private def build_display(builder : String::Builder)
        builder << "👤 #{object.name}\n".colorize.white

        builder << "📧 #{object.email}\n"
        builder << "🌍 #{object.country}\n"
        builder << "⏰ #{object.time_zone}\n"
        builder << "🔑 #{object.permissions.map(&.gsub("_", " ").titleize).join(", ")}\n"

        build_organisations(builder)
      end

      private def build_organisations(builder : String::Builder)
        builder << "\n🏢 Organisations:\n".colorize.white
        object.organisations.each do |organisation|
          builder << Organisation.new(organisation).build
        end
      end
    end
  end
end
