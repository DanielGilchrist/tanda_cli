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
          message = begin
            if organisation = config.current_organisation?
              "The current user is #{display(organisation)}"
            else
              "A current user hasn't been set!"
            end
          end

          display.puts message
        end

        private def display(organisation : Configuration::Serialisable::Organisation)
          "#{organisation.user_id} in #{organisation.name}"
        end
      end
    end
  end
end
