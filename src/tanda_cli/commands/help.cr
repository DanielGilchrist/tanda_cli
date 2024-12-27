require "./base"

module TandaCLI
  module Commands
    class Help < Cling::Command
      def initialize(@stdout : IO)
        super()
      end

      def setup : Nil
        @name = "help"
        @summary = @description = "Shows help information"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        parent = self.parent
        @stdout.puts parent.help_template if parent
      end
    end
  end
end
