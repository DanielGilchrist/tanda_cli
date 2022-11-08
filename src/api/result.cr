require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      def initialize(@value : T | Types::Error); end

      def match(&block)
        with self yield
      end

      private getter value : T | Types::Error

      private def ok(&block : T -> ::Nil)
        value = self.value
        return if value.is_a?(Types::Error)

        yield(value)
      end

      private def error(&block : Types::Error -> ::Nil)
        value = self.value
        return unless value.is_a?(Types::Error)

        yield(value)
      end
    end
  end
end
