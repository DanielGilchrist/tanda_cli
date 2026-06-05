module TandaCLI
  class Configuration
    class Serialisable
      module Environment
        class Custom
          include JSON::Serializable

          module URIConverter
            def self.from_json(value : JSON::PullParser) : URI
              URI.parse(value.read_string)
            end

            def self.to_json(value : URI, json_builder : JSON::Builder) : Nil
              json_builder.string(value.to_s)
            end
          end

          def initialize(
            @url : URI,
            @access_token : AccessToken? = nil,
            @organisations : Array(Organisation) = Array(Organisation).new,
          ); end

          @[JSON::Field(converter: TandaCLI::Configuration::Serialisable::Environment::Custom::URIConverter)]
          property url : URI

          property access_token : AccessToken?
          property organisations : Array(Organisation)

          def base_url : String
            url.to_s
          end

          def display_label : String
            "Custom (#{url})"
          end

          def current_organisation? : Organisation?
            @organisations.find(&.current?)
          end

          def current_organisation! : Organisation
            current_organisation? || raise("No current organisation set!")
          end
        end
      end
    end
  end
end
