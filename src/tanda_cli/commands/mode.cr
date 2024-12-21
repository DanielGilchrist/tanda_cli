require "./base"

module TandaCLI
  module Commands
    class Mode < Base
      def setup_
        @name = "mode"
        @summary = @description = "Set the mode to run commands in (production/staging/custom <url>)"

        add_commands(
          Mode::Production,
          Mode::Staging,
          Mode::Custom,
          Mode::Display
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        io.puts help_template
      end
    end
  end
end
