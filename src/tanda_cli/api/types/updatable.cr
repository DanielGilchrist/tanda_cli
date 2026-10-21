require "json"

module TandaCLI
  module API
    module Types
      module Updatable
        macro update_field(declaration, converter = nil)
          {% name = declaration.var %}
          {% type = declaration.type %}

          @[JSON::Field(emit_null: true, ignore_serialize: !@{{ name }}_changed, converter: {{ converter }})]
          @{{ name }} : {{ type }}?

          @[JSON::Field(ignore: true)]
          @{{ name }}_changed = false

          def {{ name }}(value : {{ type }}?) : Nil
            @{{ name }} = value
            @{{ name }}_changed = true
          end
        end
      end
    end
  end
end
