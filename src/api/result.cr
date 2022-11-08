require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      class Matcher(T)
        def initialize(@value : T | Types::Error); end

        getter value : T | Types::Error

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
      end

      def initialize(@value : T | Types::Error); end

      getter value : T | Types::Error

      def match(&block)
        with Matcher(T).new(value) yield
      end
    end
  end
end
