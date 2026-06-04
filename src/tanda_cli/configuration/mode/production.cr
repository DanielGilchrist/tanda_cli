module TandaCLI
  class Configuration
    module Mode
      struct Production
        def to_serialised_string : String
          "production"
        end

        def display_label : String
          "Production"
        end
      end
    end
  end
end
