module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Photo < CLI::Commands::Base
        def setup_
          @name = "photo"
          @summary = @description = "View, set or clear clockin photo to be used by default"

          add_commands(
            Photo::Set.new,
            Photo::View.new,
            Photo::Clear.new
          )
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          puts help_template
        end
      end
    end
  end
end
