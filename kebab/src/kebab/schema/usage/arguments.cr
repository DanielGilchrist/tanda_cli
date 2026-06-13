module Kebab
  module Schema
    module Usage
      struct Arguments
        def initialize(@command_path : Array(String), @has_options : Bool, @argument_names : Array(String))
        end

        getter command_path : Array(String)
        getter? has_options : Bool
        getter argument_names : Array(String)

        def to_s(io : IO) : Nil
          @command_path.join(io, ' ')
          io << " [options]" if @has_options
          @argument_names.each { |name| io << " <" << name << ">" }
        end
      end
    end
  end
end
