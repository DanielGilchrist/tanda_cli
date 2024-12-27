require "./base"

module TandaCLI
  module Commands
    class RegularHours < Base
      def setup_
        @name = "regular_hours"
        @summary = @description = "View or set your regular hours"

        add_commands(RegularHours::Determine, RegularHours::Display)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        stdout.puts help_template
      end
    end
  end
end
