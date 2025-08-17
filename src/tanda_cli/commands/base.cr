require "cling"
require "./help"
require "./required_scopes"

module TandaCLI
  module Commands
    abstract class Base < Cling::Command
      include RequiredScopes

      @disable_staging_warning = false

      def initialize(@context : Context)
        display = @context.@display
        super(stdout: display.@stdout, stderr: display.@stderr)
      end

      getter context : Context
      delegate client, config, current, display, input, to: context

      abstract def setup_
      abstract def run_(arguments : Cling::Arguments, options : Cling::Options)

      # overrides Cling::Command#add_commands
      def add_commands(*commands : Base.class)
        commands.each do |klass|
          add_command(klass.new(context))
        end
      end

      # override this to extend `pre_run` behaviour
      def before_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        true
      end

      def setup : Nil
        setup_

        help_command = Help.new(display)
        add_option long: "no-colour", description: "Disable ANSI colours"
        add_option 'h', help_command.name, description: help_command.description
        add_command(help_command)
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        handle_maybe_no_colour(options)

        return if help?(arguments, options)

        maybe_display_staging_warning
        handle_required_scopes!
        before_run(arguments, options)
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        if help?(arguments, options)
          help_command.run(arguments, options)
        else
          run_(arguments, options)
        end
      end

      # A hook method for when the command raises an exception during execution
      def on_error(ex : Exception)
        {% if flag?(:debug) %}
          super
        {% else %}
          display.error(ex.message || "An error occurred")
          display.puts help_template
          TandaCLI.exit!
        {% end %}
      end

      # A hook method for when the command receives missing arguments during execution
      def on_missing_arguments(arguments : Array(String))
        display.error("Missing required argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        display.puts help_template
        TandaCLI.exit!
      end

      # A hook method for when the command receives unknown arguments during execution
      def on_unknown_arguments(arguments : Array(String))
        display.error("Unknown argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        display.puts help_template
        TandaCLI.exit!
      end

      # A hook method for when the command receives an invalid option, for example, a value given to
      # an option that takes no arguments
      def on_invalid_option(message : String)
        display.error(message)
        display.puts help_template
        TandaCLI.exit!
      end

      # A hook method for when the command receives missing options that are required during
      # execution
      def on_missing_options(options : Array(String))
        display.error("Missing required option#{"s" if options.size > 1}: #{options.join(", ")}")
        display.puts help_template
        TandaCLI.exit!
      end

      # A hook method for when the command receives unknown options during execution
      def on_unknown_options(options : Array(String))
        display.error("Unknown option#{"s" if options.size > 1}: #{options.join(", ")}")
        display.puts help_template
        TandaCLI.exit!
      end

      private def maybe_display_staging_warning
        return if @disable_staging_warning
        return unless config.staging?

        message = begin
          if (mode = config.mode) != "staging"
            "Command running on #{mode}"
          else
            "Command running in staging mode"
          end
        end

        display.warning(message)
      end

      private def handle_maybe_no_colour(options : Cling::Options)
        return unless options.has?("no-colour")

        Colorize.enabled = false
      end

      private def help?(arguments : Cling::Arguments, options : Cling::Options) : Bool
        arguments.has?("help") || options.has?("help")
      end

      private def help_command : Cling::Command
        children["help"]
      end
    end
  end
end
