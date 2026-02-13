require "colorize"

require "./base"
require "../types/me/**"

module TandaCLI
  module Representers
    struct Me < Base(Types::Me)
      private def build_display(builder : Builder)
        builder << "👤 #{@object.name}\n".colorize.white.bold

        builder << "📧 #{@object.email}\n"
        builder << "🌍 #{@object.country}\n"
        builder << "🔑 #{@object.permissions.map(&.gsub("_", " ").titleize).join(", ")}\n"

        build_organisations(builder)
      end

      private def build_organisations(builder : Builder)
        builder << "\n🏢 Organisations:\n".colorize.white.bold
        last_organisation_index = @object.organisations.size - 1
        @object.organisations.each_with_index do |organisation, index|
          Organisation.new(organisation).build(builder)
          builder << '\n' if index != last_organisation_index
        end
      end
    end
  end
end
