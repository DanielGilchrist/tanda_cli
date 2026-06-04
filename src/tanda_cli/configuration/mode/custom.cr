module TandaCLI
  class Configuration
    module Mode
      struct Custom
        def initialize(@url : URI); end

        getter url : URI

        def to_serialised_string : String
          url.to_s
        end

        def display_label : String
          "Custom (#{url})"
        end
      end
    end
  end
end
