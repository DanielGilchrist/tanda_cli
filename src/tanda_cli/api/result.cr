require "../types/error"

module TandaCLI
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
        {% if T == Nil %}
          # Nil is a special case we use if we don't care about the value for a successful response
        {% elsif T < JSON::Serializable %}
          # Allow types that include `JSON::Serializable`
        {% elsif T < Array && T.type_vars.all?(&.<(JSON::Serializable)) %}
          # Allow array types only if they only contain objects that include JSON::Serializable
        {% else %}
          # If above conditions aren't met, throw a compiler error
          {{ raise "Unsupported type #{T}" }}
        {% end %}

        # Handles the case that the response is "blank" but still needs to be parsed into a specific object
        body = response.body
        body = %({}) if body.presence.nil?

        {% if T == Nil %}
          # Special case - if we don't care about a successful response's value we use Nil
          response.success? ? nil : Types::Error.from_json(body)
        {% else %}
          (response.success? ? T : Types::Error).from_json(body)
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
    end
  end
end
