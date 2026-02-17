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
            display.puts "#{organisation.name.colorize.white.bold} (User #{organisation.user_id})"
          else
            display.puts "A current user hasn't been set!"
          end
        end
      end
    end
  end
end
