require "colorize"

module Tanda::CLI
  module Utils
    module Display
      extend self

      SUCCESS_STRING = "Success:".colorize(:green)
      WARNING_STRING = "Warning:".colorize(:yellow)
      ERROR_STRING = "Error:".colorize(:red)
      FATAL_STRING = "FATAL ERROR:".colorize(:red)

      enum Type
        Success
        Warning
        Error
        Fatal
      end

      def success(message : String, value = nil)
        display_message(Type::Success, message, value)
      end

      def warning(message : String)
        display_message(Type::Warning, message)
      end

      def fatal!(message : String) : NoReturn
        {% if flag?(:debug) || flag?(:test) %}
          raise message
        {% else %}
          display_message(Type::Fatal, message)
          exit
        {% end %}
      end

      def fatal!(exception : Exception) : NoReturn
        {% if flag?(:debug) || flag?(:test) %}
          raise exception
        {% else %}
          message = exception.message || "An irrecoverable error occured"
          display_message(Type::Fatal, message)
          exit
        {% end %}
      end

      def error(message : String, value = nil)
        display_message(Type::Error, message, value)
      end

      def error(message : String, value = nil, &block : IO -> Nil)
        error(message, value)

        string = String.build do |io|
          yield(io)
        end

        string.split("\n").each(&-> sub_error(String))
      end

      def error(error_object : Types::Error)
        error(error_object.error)

        error_description = error_object.error_description
        sub_error(error_description) if error_description
      end

      def error!(message : String, value = nil) : NoReturn
        error(message, value)
        exit
      end

      def error!(message : String, value = nil, &block : IO -> Nil) : NoReturn
        error(message, value, &block)
        exit
      end

      def error!(error_object : Types::Error) : NoReturn
        error(error_object)
        exit
      end

      private def sub_error(message : String)
        puts "#{" " * ERROR_STRING.default.to_s.size} #{message}"
      end

      private def display_message(type, message : String, value = nil)
        puts "#{prefix(type)} #{message}#{value && " \"#{value}\""}"
      end

      private def prefix(type : Type) : Colorize::Object(String)
        case type
        in Type::Success
          SUCCESS_STRING
        in Type::Warning
          WARNING_STRING
        in Type::Error
          ERROR_STRING
        in Type::Fatal
          FATAL_STRING
        end
      end
    end
  end
end
