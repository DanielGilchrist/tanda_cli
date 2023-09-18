require "cling"

module Tanda::CLI
  module CLI::Commands
    class Help < Cling::Command
      def setup : Nil
        @name = "help"
        @summary = @description = "Shows help information"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        parent = self.parent
        puts parent.help_template if parent
      end
    end
  end
end
