module TandaCLI
  module API
    struct Result(T) < TandaCLI::AbstractResult(T, Types::Error)
      def self.from(response : HTTP::Client::Response) : self
        new(parse(response))
      end

      # allows additional processing on a successful response
      def self.from(response : HTTP::Client::Response, & : T -> T | E) : self
        case result = parse(response)
        in E
          new(result)
        in T
          new(yield(result))
        end
      end

      private def self.parse(response : HTTP::Client::Response) : T | E
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
          response.success? ? nil : E.from_json(body)
        {% else %}
          (response.success? ? T : E).from_json(body)
        {% end %}
      end
    end
  end
end
