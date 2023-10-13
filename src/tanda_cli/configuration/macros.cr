module TandaCLI
  class Configuration
    module Macros
      #
      # Defines getter and setter methods for accessing `Configuration::Environment` methods based on `Configuration#mode`
      #
      # Example:
      # ```
      # environment_property time_zone : String?
      #
      # # expands to
      #
      # def time_zone : String | ::Nil
      #   current_environment.time_zone
      # end
      #
      # def time_zone=(value : String | ::Nil)
      #   current_environment.time_zone = value
      # end
      # ```
      #
      macro environment_property(name)
        def {{name.var.id}} : {{name.type}}
          current_environment.{{name.var.id}}
        end

        def {{name.var.id}}=(value : {{name.type}})
          current_environment.{{name.var.id}} = value
        end
      end
    end
  end
end
