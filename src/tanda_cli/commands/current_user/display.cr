require "../base"

module TandaCLI
  module Commands
    class CurrentUser
      class Display < Base
        def setup_
          @name = "display"
          @summary = @description = "Display the current user"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          if organisation = config.current_organisation?
            stdout.puts "The current user is #{display(organisation)}"
          else
            stdout.puts "A current user hasn't been set!"
          end
        end

        private def display(organisation : Configuration::Serialisable::Organisation)
          "#{organisation.user_id} in #{organisation.name}"
        end
      end
    end
  end
end
