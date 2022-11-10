require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      # TODO: This method is unsafe - Look into if it's possible to restrict `T` here
      # If `T` is a non `JSON::Serializable` type the compiler doesn't catch it and crashes during runtime
      def self.from(response : HTTP::Client::Response) : API::Result(T)
        result = (response.success? ? T : Types::Error).from_json(response.body)
        new(result)
      end

      def initialize(@value : T | Types::Error); end

      def match(&block)
        with self yield
      end

      def or(&block)
        value = self.value
        return value unless value.is_a?(Types::Error)

        yield(value)
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
