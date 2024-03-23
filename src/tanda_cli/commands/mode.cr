require "./base"

module TandaCLI
  module Commands
    class Mode < Base
      @disable_staging_warning = true

      def setup_
        @name = "mode"
        @summary = @description = "Set the mode to run commands in (production/staging/custom <url>)"

        add_commands(
          Mode::Production.new,
          Mode::Staging.new,
          Mode::Custom.new,
          Mode::Display.new
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
