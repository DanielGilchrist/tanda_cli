require "colorize"

require "./error/base"

module TandaCLI
  class Display
    enum Type
      Success
      Info
      Warning
      Error
      Fatal
    end

    def initialize(@stdout : IO, @stderr : IO); end

    def success(message : String, value : String? = nil)
      display_message(:success, message, value)
    end

    def info(message : String, value : String? = nil)
      display_message(:info, message, value)
    end

    def warning(message : String)
      display_message(:warning, message)
    end

    def fatal!(message : String) : NoReturn
      {% if flag?(:debug) && !flag?(:test) %}
        raise message
      {% else %}
        display_message(:fatal, message)
        TandaCLI.exit!
      {% end %}
    end

    def error(message : String, value : String? = nil)
      display_message(:error, message, value)
    end

    def error(message : String, value : String? = nil, & : String::Builder ->)
      error(message, value)

      string = String.build do |builder|
        yield(builder)
      end
      return if string.empty?

      string.split("\n").each { |error_string| sub_error(error_string) }
    end

    def error(error_object : Error::Interface)
      error(error_object.error)

      error_description = error_object.error_description
      sub_error(error_description) if error_description
    end

    def error!(message : String, value : String? = nil) : NoReturn
      error(message, value)
      TandaCLI.exit!
    end

    def error!(message : String, value : String? = nil, &block : String::Builder ->) : NoReturn
      error(message, value, &block)
      TandaCLI.exit!
    end

    def error!(error_object : Error::Base) : NoReturn
      {% if flag?(:debug) && !flag?(:test) %}
        raise error_object
      {% else %}
        error(error_object)
        TandaCLI.exit!
      {% end %}
    end

    def error!(error_object : Error::Interface) : NoReturn
      error(error_object)
      TandaCLI.exit!
    end

    def puts(message = nil)
      @stdout.puts message
    end

    def print(message)
      @stdout.print message
    end

    def puts_error(message = nil)
      @stderr.puts message
    end

    private def sub_error(message : String)
      puts_error "#{" " * raw_size(error_string)} #{message}"
    end

    private def display_message(type : Type, message : String, value : String? = nil)
      message = "#{prefix(type)} #{message}#{value && " \"#{value}\""}"

      case type
      when .error?, .fatal?
        puts_error message
      else
        puts message
      end
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
