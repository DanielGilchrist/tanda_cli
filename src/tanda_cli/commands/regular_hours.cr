require "./base"

module TandaCLI
  module Commands
    class RegularHours < Base
      def setup_
        @name = "regular_hours"
        @summary = @description = "View or set your regular hours"

        add_commands(RegularHours::Determine.new, RegularHours::Display.new)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Utils::Display.print help_template
      end
    end
  end
end
