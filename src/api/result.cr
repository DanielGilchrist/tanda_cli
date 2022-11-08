require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      class Matcher(T)
        def initialize(@value : T | Types::Error); end

        def ok(&block : T -> ::Nil)
          value = self.value
          return if value.is_a?(Types::Error)

          yield(value)
        end

        def error(&block : Types::Error -> ::Nil)
          value = self.value
          return unless value.is_a?(Types::Error)

          yield(value)
        end

        private getter value : T | Types::Error
      end

      def initialize(@value : T | Types::Error); end

      def match(&block)
        with Matcher(T).new(value) yield
      end

      private getter value : T | Types::Error
    end
  end
end
