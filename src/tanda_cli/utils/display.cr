require "colorize"

require "../error/base"

module TandaCLI
  module Utils
    module Display
      extend self

      enum Type
        Success
        Info
        Warning
        Error
        Fatal
      end

      def success(message : String, value : String? = nil, io = STDOUT)
        display_message(Type::Success, message, value, io)
      end

      def info(message : String, value : String? = nil, io = STDOUT)
        display_message(Type::Info, message, value, io)
      end

      def warning(message : String, io = STDOUT)
        display_message(Type::Warning, message, io: io)
      end

      def info!(message : String, value : String? = nil, io = STDOUT) : NoReturn
        info(message, value, io)
        TandaCLI.exit!
      end

      def fatal!(message : String, io = STDOUT) : NoReturn
        {% if flag?(:debug) && !flag?(:test) %}
          raise message
        {% else %}
          display_message(Type::Fatal, message, io: io)
          TandaCLI.exit!
        {% end %}
      end

      def error(message : String, value : String? = nil, io = STDOUT)
        display_message(Type::Error, message, value, io)
      end

      def error(message : String, value : String? = nil, io = STDOUT, & : String::Builder ->)
        error(message, value)

        string = String.build do |builder|
          yield(builder)
        end
        return if string.empty?

        string.split("\n").each { |error_string| sub_error(error_string, io) }
      end

      def error(error_object : Error::Interface, io = STDOUT)
        error(error_object.error, io: io)

        error_description = error_object.error_description
        sub_error(error_description, io) if error_description
      end

      def error!(message : String, value : String? = nil, io = STDOUT) : NoReturn
        error(message, value, io)
        TandaCLI.exit!
      end

      def error!(message : String, value : String? = nil, io = STDOUT, &block : String::Builder ->) : NoReturn
        error(message, value, io, &block)
        TandaCLI.exit!
      end

      def error!(error_object : Error::Base, io = STDOUT) : NoReturn
        {% if flag?(:debug) && !flag?(:test) %}
          raise error_object
        {% else %}
          error(error_object, io)
          TandaCLI.exit!
        {% end %}
      end

      def error!(error_object : Error::Interface, io = STDOUT) : NoReturn
        error(error_object, io)
        TandaCLI.exit!
      end

      private def sub_error(message : String, io = STDOUT)
        print("#{" " * raw_size(error_string)} #{message}", io)
      end

      private def display_message(type, message : String, value : String? = nil, io = STDOUT)
        print("#{prefix(type)} #{message}#{value && " \"#{value}\""}", io)
      end

      private def prefix(type : Type) : Colorize::Object(String)
        case type
        in .success?
          success_string
        in .info?
          info_string
        in .warning?
          warning_string
        in .error?
          error_string
        in .fatal?
          fatal_string
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

      private def success_string : Colorize::Object(String)
        "Success:".colorize.green
      end

      private def info_string : Colorize::Object(String)
        "Info:".colorize.light_green
      end

      private def warning_string : Colorize::Object(String)
        "Warning:".colorize.yellow
      end

      private def error_string : Colorize::Object(String)
        "Error:".colorize.light_red
      end

      private def fatal_string : Colorize::Object(String)
        "Fatal:".colorize.red
      end
    end
  end
end
