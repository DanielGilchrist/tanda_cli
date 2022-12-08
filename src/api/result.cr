require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      def self.from(response : HTTP::Client::Response) : API::Result(T)
        {% if T < JSON::Serializable %}
          # Allow types that include `JSON::Serializable`
        {% elsif T.has_method?(:to_json) %}
          # This accounts for stdlib types like `Array` that are "serializable"
        {% else %}
          # If above conditions aren't met, throw a compiler error
          {{ raise "Unsupported type #{T}" }}
        {% end %}

        # TODO-ameba: Pending https://github.com/crystal-ameba/ameba/issues/318
        # ameba:disable Lint/LiteralsComparison
        result = {% if T == Nil %}
          # Special case - if we don't care about a successful response's value we use Nil
          response.success? ? nil : Types::Error.from_json(response.body)
        {% else %}
          (response.success? ? T : Types::Error).from_json(response.body)
        {% end %}

        new(result)
      end

      # allows additional processing on a successful response
      def self.from(response : HTTP::Client::Response, & : T -> T | Types::Error) : API::Result(T)
        {% if T < JSON::Serializable %}
          # Allow types that include `JSON::Serializable`
        {% elsif T.has_method?(:to_json) %}
          # This accounts for stdlib types like `Array` that are "serializable"
        {% else %}
          # If above conditions aren't met, throw a compiler error
          {{ raise "Unsupported type #{T}" }}
        {% end %}

        result = (response.success? ? T : Types::Error).from_json(response.body)
        return new(result) if result.is_a?(Types::Error)

        new(yield(result))
      end

      # This class should only be initialized with the `from` method
      private def initialize(@value : T | Types::Error); end

      def match(&) : ::Nil
        with self yield

        nil
      end

      def or(& : Types::Error -> _)
        value = self.value
        return value unless value.is_a?(Types::Error)

        yield(value)
      end

      private getter value : T | Types::Error

      private def ok(& : T -> _) : ::Nil
        value = self.value
        return if value.is_a?(Types::Error)

        yield(value)

        nil
      end

      private def error(& : Types::Error -> _) : ::Nil
        value = self.value
        return unless value.is_a?(Types::Error)

        yield(value)

        nil
      end
    end
  end
end
