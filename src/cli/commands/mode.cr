require "./base"

module Tanda::CLI
  module CLI::Commands
    class Mode < Base
      def on_setup
        @name = "mode"
        @summary = @description = "Set the mode to run commands in (production/staging/custom <url>)"

        add_commands(
          Mode::Production.new,
          Mode::Staging.new,
          Mode::Custom.new,
          Mode::Display.new
        )
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
