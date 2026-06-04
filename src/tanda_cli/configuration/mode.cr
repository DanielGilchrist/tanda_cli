require "../utils/url"

module TandaCLI
  class Configuration
    module Mode
      alias Any = Production | Staging | Custom

      def self.from_string(value : String) : Any | Error::InvalidURL
        case value
        when "production" then Production.new
        when "staging"    then Staging.new
        else
          case validated = Utils::URL.validate(value)
          in URI
            Custom.new(validated)
          in Error::InvalidURL
            validated
          end
        end
      end

      module Converter
        def self.from_json(value : JSON::PullParser) : Any
          raw = value.read_string
          case parsed = Mode.from_string(raw)
          in Any
            parsed
          in Error::InvalidURL
            raise JSON::ParseException.new("Invalid mode \"#{raw}\": #{parsed.error}", 0, 0)
          end
        end

        def self.to_json(value : Any, json_builder : JSON::Builder) : Nil
          json_builder.string(value.to_serialised_string)
        end
      end
    end
  end
end
