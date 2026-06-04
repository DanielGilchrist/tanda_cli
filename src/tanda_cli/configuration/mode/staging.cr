module TandaCLI
  class Configuration
    module Mode
      struct Staging
        def to_serialised_string : String
          "staging"
        end

        def display_label : String
          "Staging"
        end
      end
    end
  end
end
