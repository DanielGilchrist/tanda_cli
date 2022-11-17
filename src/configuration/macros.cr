module Tanda::CLI
  class Configuration
    module Macros
      abstract def staging? : Bool

      #
      # Defines getter and setter methods for accessing Configuration::Environment methods based on mode
      # Example:
      # mode_property time_zone : String?
      #
      # expands to
      #
      # def time_zone : String | ::Nil
      #   if staging?
      #     config.staging.time_zone
      #   else
      #     config.production.time_zone
      #   end
      # end
      #
      # def time_zone=(value : String | ::Nil)
      #   if staging?
      #     config.staging.time_zone = value
      #   else
      #     config.production.time_zone = value
      #   end
      # end
      #
      macro mode_property(name)
        def {{name.var.id}} : {{name.type}}
          if staging?
            config.staging.{{name.var.id}}
          else
            config.production.{{name.var.id}}
          end
        end

        def {{name.var.id}}=(value : {{name.type}})
          if staging?
            config.staging.{{name.var.id}} = value
          else
            config.production.{{name.var.id}} = value
          end
        end
        {{debug}}
      end
    end
  end
end
