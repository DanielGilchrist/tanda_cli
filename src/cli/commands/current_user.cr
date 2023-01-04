module Tanda::CLI
  module CLI::Commands
    class CurrentUser
      def initialize(@config : Configuration, @id_or_name : String?, @list : Bool = false); end

      def execute
        puts "\n"
        display_organisations! if list

        id_or_name = self.id_or_name
        return display_current_user if id_or_name.nil?

        try_set_new_current_user!(id_or_name)
      end

      private getter config
      private getter id_or_name
      private getter list

      private def display_current_user
        if organisation = config.organisations.find(&.current?)
          puts "The current user is #{display(organisation)}"
        else
          puts "A current user hasn't been set!"
        end
      end

      private def try_set_new_current_user!(id_or_name : String)
        organisation = begin
          if (user_id = id_or_name.to_i?)
            config.organisations.find(&.user_id.==(user_id))
          else
            input_name = id_or_name.downcase
            config.organisations.find(&.name.downcase.includes?(input_name))
          end
        end

        Utils::Display.error!("Invalid argument", id_or_name) if organisation.nil?

        config.organisations.each(&.current = false)
        organisation.current = true
        config.save!

        Utils::Display.success("The current user has been set to", display(organisation))
      end

      def display_organisations!
        config.organisations.each do |organisation|
          puts "Name: #{organisation.name}\nUser ID: #{organisation.user_id}\n\n"
        end
        exit
      end

      private def display(organisation : Configuration::Organisation)
        "#{organisation.user_id} in #{organisation.name}"
      end
    end
  end
end
