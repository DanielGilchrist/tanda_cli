require "colorize"

module Kebab
  module Error
    abstract class Base
      def initialize(@error : String, @error_description : String? = nil)
      end

      getter error : String
      getter error_description : String?

      def to_s(io : IO) : Nil
        io << "Error:".colorize.red.bold << ' ' << @error
        if description = @error_description
          io << '\n' << "       " << description
        end
      end
    end
  end
end
