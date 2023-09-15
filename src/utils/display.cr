require "colorize"

require "../error/base"

module Tanda::CLI
  module Utils
    module Display
      extend self

      SUCCESS_STRING = "Success:".colorize.green
      INFO_STRING    = "Info:".colorize.light_green
      WARNING_STRING = "Warning:".colorize.yellow
      ERROR_STRING   = "Error:".colorize.light_red
      FATAL_STRING   = "Fatal:".colorize.red

      enum Type
        Success
        Info
        Warning
        Error
        Fatal
      end

      def success(message : String, value = nil)
        display_message(Type::Success, message, value)
      end

      def info(message : String, value = nil)
        display_message(Type::Info, message, value)
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

      def error(message : String, value = nil, & : String::Builder ->)
        error(message, value)

        string = String.build do |builder|
          yield(builder)
        end
        return if string.empty?

        string.split("\n").each(&->sub_error(String))
      end

      def error(error_object : Error::Interface)
        error(error_object.error)

        error_description = error_object.error_description
        sub_error(error_description) if error_description
      end

      def error!(message : String, value = nil) : NoReturn
        error(message, value)
        exit
      end

      def error!(message : String, value = nil, &block : String::Builder ->) : NoReturn
        error(message, value, &block)
        exit
      end

      def error!(error_object : Error::Base) : NoReturn
        {% if flag?(:debug) || flag?(:test) %}
          raise error_object
        {% else %}
          error(error_object)
          exit
        {% end %}
      end

      def error!(error_object : Error::Interface) : NoReturn
        error(error_object)
        exit
      end

      private def sub_error(message : String)
        puts "#{" " * raw_size(ERROR_STRING)} #{message}"
      end

      private def display_message(type, message : String, value = nil)
        puts "#{prefix(type)} #{message}#{value && " \"#{value}\""}"
      end

      private def prefix(type : Type) : Colorize::Object(String)
        case type
        in Type::Success
          SUCCESS_STRING
        in Type::Info
          INFO_STRING
        in Type::Warning
          WARNING_STRING
        in Type::Error
          ERROR_STRING
        in Type::Fatal
          FATAL_STRING
        end
      end

      # Gets the size of the string without the colour codes
      # "Error:".colorize.red.to_s         => "\e[31m\"Error:\"\e[0m" => 15
      # "Error:".colorize.red.default.to_s => "Error:"                => 6
      private def raw_size(colorized_string : Colorize::Object(String)) : UInt8
        colorized_string.default.to_s.size.to_u8
      end
    end
  end
end
