require "../base"

module Tanda::CLI
  module CLI::Commands
    class CurrentUser
      class List < Base
        def on_setup
          @name = "list"
          @summary = @description = "List available current users"
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          Current.config.organisations.each do |organisation|
            puts "Name: #{organisation.name}\nUser ID: #{organisation.user_id}\n\n"
          end
        end
      end
    end
  end
end
