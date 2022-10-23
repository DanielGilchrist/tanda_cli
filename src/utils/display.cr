require "colorize"

module Tanda::CLI
  module Utils
    module Display
      extend self

      SUCCESS_STRING = "Success:".colorize(:green)
      ERROR_STRING = "Error:".colorize(:red)

      enum Type
        Success
        Error
      end

      def success(message : String, value = nil)
        display_message(Type::Success, message, value)
      end

      def error(message : String, value = nil)
        display_message(Type::Error, message, value)
      end

      private def display_message(type, message : String, value)
        puts "#{prefix(type)} #{message}#{value && " \"#{value}\""}"
      end

      private def prefix(type : Type) : Colorize::Object(String)
        case type
        when Type::Success
          SUCCESS_STRING
        when Type::Error
          ERROR_STRING
        else
          raise "Unknown type #{type}"
        end
      end
    end
  end
end
