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

      # A hook method for when the command raises an exception during execution
      def on_error(ex : Exception)
        {% if flag?(:debug) %}
          super
        {% else %}
          Utils::Display.error(ex.message || "An error occurred")
          puts help_template
          exit
        {% end %}
      end

      # A hook method for when the command receives missing arguments during execution
      def on_missing_arguments(arguments : Array(String))
        Utils::Display.error("Missing required argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        puts help_template
        exit
      end

      # A hook method for when the command receives unknown arguments during execution
      def on_unknown_arguments(arguments : Array(String))
        Utils::Display.error("Unknown argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        puts help_template
        exit
      end

      # A hook method for when the command receives an invalid option, for example, a value given to
      # an option that takes no arguments
      def on_invalid_option(message : String)
        Utils::Display.error(message)
        puts help_template
        exit
      end

      # A hook method for when the command receives missing options that are required during
      # execution
      def on_missing_options(options : Array(String))
        Utils::Display.error("Missing required option#{"s" if options.size > 1}: #{options.join(", ")}")
        puts help_template
        exit
      end

      # A hook method for when the command receives unknown options during execution
      def on_unknown_options(options : Array(String))
        Utils::Display.error("Unknown option#{"s" if options.size > 1}: #{options.join(", ")}")
        puts help_template
        exit
      end
    end
  end
end
