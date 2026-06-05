module TandaCLI
  class Configuration
    class Serialisable
      module Environment
        alias Any = Production | Staging | Custom

        enum Name
          Production
          Staging
          Custom

          def to_json(builder : JSON::Builder) : Nil
            builder.string(to_s.downcase)
          end
        end
      end
    end
  end
end
