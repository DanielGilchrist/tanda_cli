module Kebab
  module Error
    # A parse-time error. Plain value class — NOT an Exception subclass — so
    # the public `parse` return type union (`T | Help | Errors`) doesn't
    # collapse to `Exception` and break the caller's `case ... in`
    # exhaustiveness. Unwinding out of nested `initialize`s is done by
    # `Internal::ParseExit` (which IS the exception).
    abstract class Base
      def initialize(@error : String, @error_description : String? = nil)
      end

      getter error : String
      getter error_description : String?
    end
  end
end
