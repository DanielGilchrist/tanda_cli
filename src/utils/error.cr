require "colorize"

module Tanda::CLI
  module Utils
    module Error
      extend self

      ERROR_STRING = "Error:".colorize(:red)

      def display(message : String)
        puts "#{ERROR_STRING} #{message}"
      end
    end
  end
end
