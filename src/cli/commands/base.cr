require "cling"
require "./help"

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

        help_command = Help.new
        add_option 'h', help_command.name, description: help_command.description
        add_command(help_command)
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
