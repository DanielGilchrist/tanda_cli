require "colorize"

require "../error/base"

module TandaCLI
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

      def success(message : String, value = nil,  io = STDOUT)
        display_message(Type::Success, message, value, io)
      end

      def info(message : String, value = nil,  io = STDOUT)
        display_message(Type::Info, message, value, io)
      end

      def warning(message : String,  io = STDOUT)
        display_message(Type::Warning, message, io)
      end

      def info!(message : String, value = nil,  io = STDOUT) : NoReturn
        info(message, value, io)
        exit
      end

      def fatal!(message : String,  io = STDOUT) : NoReturn
        {% if flag?(:debug) || flag?(:test) %}
          raise message
        {% else %}
          display_message(Type::Fatal, message, io)
          exit
        {% end %}
      end

      def error(message : String, value = nil,  io = STDOUT)
        display_message(Type::Error, message, value, io)
      end

      def error(message : String, value = nil,  io = STDOUT, & : String::Builder ->)
        error(message, value)

        string = String.build do |builder|
          yield(builder)
        end
        return if string.empty?

        string.split("\n").each { |error_string| sub_error(error_string, io) }
      end

      def error(error_object : Error::Interface,  io = STDOUT)
        error(error_object.error, io)

        error_description = error_object.error_description
        sub_error(error_description, io) if error_description
      end

      def error!(message : String, value = nil,  io = STDOUT) : NoReturn
        error(message, value, io)
        exit
      end

      def error!(message : String, value = nil,  io = STDOUT, &block : String::Builder ->) : NoReturn
        error(message, value, io, &block)
        exit
      end

      def error!(error_object : Error::Base,  io = STDOUT) : NoReturn
        {% if flag?(:debug) || flag?(:test) %}
          raise error_object
        {% else %}
          error(error_object)
          exit
        {% end %}
      end

      def error!(error_object : Error::Interface,  io = STDOUT) : NoReturn
        error(error_object, io)
        exit
      end

      private def sub_error(message : String,  io = STDOUT)
        print("#{" " * raw_size(ERROR_STRING)} #{message}", io)
      end

      private def display_message(type, message : String, value = nil,  io = STDOUT)
        print("#{prefix(type)} #{message}#{value && " \"#{value}\""}", io)
      end

      private def prefix(type : Type) : Colorize::Object(String)
        case type
        in .success?
          SUCCESS_STRING
        in .info?
          INFO_STRING
        in .warning?
          WARNING_STRING
        in .error?
          ERROR_STRING
        in .fatal?
          FATAL_STRING
        end
      end

      # Gets the size of the string without the colour codes
      # "Error:".colorize.red.to_s         => "\e[31m\"Error:\"\e[0m" => 15
      # "Error:".colorize.red.default.to_s => "Error:"                => 6
      private def raw_size(colorized_string : Colorize::Object(String)) : UInt8
        colorized_string.default.to_s.size.to_u8
      end

      def print(output : String, io : IO)
        io.puts output
      end
    end
  end
end
