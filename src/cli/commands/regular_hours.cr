require "./base"

module Tanda::CLI
  module CLI::Commands
    class RegularHours < Base
      def on_setup
        @name = "regular_hours"
        @summary = @description = "View or set your regular hours"

        add_commands(RegularHours::Determine.new, RegularHours::Display.new)
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
