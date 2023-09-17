require "cling"

module Tanda::CLI
  module CLI::Commands
    abstract class Base < Cling::Command
      abstract def on_setup

      # override this to extend `pre_run` behaviour
      def before_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        true
      end

      def setup : Nil
        on_setup
        add_option 'h', "help", description: "sends help information"
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        if options.has?("help")
          puts help_template

          false
        else
          before_run(arguments, options)
        end
      end
    end
  end
end
