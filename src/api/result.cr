require "../types/error"

module Tanda::CLI
  module API
    class Result(T)
      def self.from(response : HTTP::Client::Response) : self
        new(parse(response))
      end

      # allows additional processing on a successful response
      def self.from(response : HTTP::Client::Response, & : T -> T | Types::Error) : self
        case result = parse(response)
        in Types::Error
          new(result)
        in T
          new(yield(result))
        end
      end

      private def self.parse(response : HTTP::Client::Response) : T | Types::Error
        {% if T < JSON::Serializable %}
          # Allow types that include `JSON::Serializable`
        {% elsif T.has_method?(:to_json) %}
          # This accounts for stdlib types like `Array` that are "serializable"
        {% else %}
          # If above conditions aren't met, throw a compiler error
          {{ raise "Unsupported type #{T}" }}
        {% end %}

        {% if T == Nil %}
          # Special case - if we don't care about a successful response's value we use Nil
          response.success? ? nil : Types::Error.from_json(response.body)
        {% else %}
          (response.success? ? T : Types::Error).from_json(response.body)
        {% end %}
      end

      # This class should only be initialized with the `from` class method
      private def initialize(@value : T | Types::Error); end

      def or(& : Types::Error -> U) : T | U forall U
        case value = @value
        in T
          value
        in Types::Error
          yield(value)
        end
      end

      def or? : T?
        case value = @value
        in T
          value
        in Types::Error
          nil
        end
      end
    end
  end
end
