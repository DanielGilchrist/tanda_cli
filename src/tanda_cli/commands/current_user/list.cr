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
          context.config.organisations.each do |organisation|
            puts "Name: #{organisation.name}\nUser ID: #{organisation.user_id}\n\n"
          end
        end
      end
    end
  end
end
