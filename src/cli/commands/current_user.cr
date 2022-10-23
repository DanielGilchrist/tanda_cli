module Tanda::CLI
  module CLI::Commands
    class CurrentUser
      def initialize(client : API::Client, config : Configuration, id_or_name : String?)
        @client = client
        @config = config
        @id_or_name = id_or_name
      end

      def execute
        puts "\n"

        id_or_name = self.id_or_name
        return display_current_user if id_or_name.nil?

        try_set_new_current_user!(id_or_name)
      end

      private getter client
      private getter config
      private getter id_or_name

      private def display_current_user
        if organisation = config.organisations.find(&.current?)
          puts "The current user is #{display(organisation)}"
        else
          puts "A current user hasn't been set!"
        end
      end

      private def try_set_new_current_user!(id_or_name : String)
        maybe_user_id = id_or_name.to_i32?
        organisation = config.organisations.find do |org|
          if maybe_user_id
            org.user_id == maybe_user_id
          else
            name = org.name.downcase
            input_name = id_or_name.downcase

            name.includes?(input_name)
          end
        end

        return user_not_found! if organisation.nil?

        config.organisations.each(&.current = false)
        organisation.current = true
        config.save!

        puts "The current user has been set to #{display(organisation)}"
      end

      private def user_not_found!
        Utils::Error.display("Invalid argument \"#{id_or_name}\"")
      end

      private def display(organisation : Configuration::Organisation)
        "#{organisation.user_id} in #{organisation.name}"
      end
    end
  end
end
