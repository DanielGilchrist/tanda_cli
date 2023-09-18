module Tanda::CLI
  module CLI::Commands
    class ClockIn
      class Break < CLI::Commands::Base
        def setup_
          @name = "break"
          @summary = @description = "Clock a break"
          @inherit_options = true

          add_commands(Break::Start.new, Break::Finish.new)
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          puts help_template
        end
      end
    end
  end
end
