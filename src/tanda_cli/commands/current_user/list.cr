require "../base"

module TandaCLI
  module Commands
    class CurrentUser
      class List < Base
        def setup_
          @name = "list"
          @summary = @description = "List available current users"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config.organisations.each do |organisation|
            current = organisation.current? ? " #{"(current)".colorize.green}" : ""
            display.puts "#{organisation.name.colorize.white.bold}#{current}"
            display.puts "User ID: #{organisation.user_id}\n\n"
          end
        end
      end
    end
  end
end
