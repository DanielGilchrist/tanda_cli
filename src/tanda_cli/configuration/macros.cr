module TandaCLI
  class Configuration
    module Macros
      #
      # Defines getter and setter methods for accessing `Configuration::Environment` methods based on `Configuration#mode`
      #
      # Example:
      # ```
      # environment_property site_prefix : String?
      #
      # # expands to
      #
      # def site_prefix : String | ::Nil
      #   current_environment.site_prefix
      # end
      #
      # def site_prefix=(value : String | ::Nil)
      #   current_environment.site_prefix = value
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
