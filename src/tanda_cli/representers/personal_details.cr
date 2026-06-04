require "colorize"

require "./base"
require "../api/types/personal_details/**"

module TandaCLI
  module Representers
    struct PersonalDetails < Base(API::Types::PersonalDetails)
      private def build_display(builder : Builder)
        builder << "📖 Personal Details\n".colorize.white

        builder << "📧 #{@object.email}\n"

        gender = @object.gender
        builder << "⚧ #{gender}\n" if gender

        tax_file_number = @object.tax_file_number
        builder << "🪪 #{tax_file_number}\n" if tax_file_number

        build_emergency_contacts(builder)
        build_address(builder)
      end

      private def build_emergency_contacts(builder : Builder)
        return if @object.emergency_contacts.empty?

        builder << "\n🚑 Emergency Contacts\n".colorize.white.bold

        @object.emergency_contacts.each do |contact|
          EmergencyContact.new(contact).build(builder)
        end
      end

      private def build_address(builder : Builder)
        address = @object.residential_address
        return if address.nil?

        builder << "\n🏠 Address\n".colorize.white.bold
        Address.new(address).build(builder)
        builder << '\n'
      end
    end
  end
end
