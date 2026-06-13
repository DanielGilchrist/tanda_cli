require "./convert"
require "./errors"
require "./help"
require "./internal"
require "./scanner"

module Kebab
  module Parseable
    macro included
      # `parse` returns one of three concrete outcomes: the parsed struct, a
      # `Help` request, or one of the `Kebab::Errors` variants. Callers
      # `case ... in` exhaustively — no abstract `Error::Base` in the public
      # surface.
      #
      # Only `Internal::ParseExit` (raised by our own bail helper) is rescued;
      # anything else — a converter bug, a user `raise` — propagates normally.
      def self.parse(args : Array(String)) : self | ::Kebab::Help | ::Kebab::Errors
        new(__kebab_args: args)
      rescue ex : ::Kebab::Internal::ParseExit
        ex.result
      end
    end

    # Default `run(context)` for command structs.
    #
    # - Subcommand-bearing structs auto-dispatch to the chosen subcommand (the
    #   field is never nil — `parse` returns `Help` upfront if no subcommand
    #   is given and the annotation isn't `required: true`).
    # - Leaf commands must override this with their own `def run(context : T)`;
    #   that overload wins via Crystal's standard overload resolution.
    def run(context) : Nil
      {% begin %}
        {% subcommand_ivar = @type.instance_vars.find(&.annotation(::Kebab::Subcommand)) %}
        {% if subcommand_ivar %}
          @{{subcommand_ivar.id}}.run(context)
        {% else %}
          raise "#{self.class}#run(context) must be defined"
        {% end %}
      {% end %}
    end

    # NOTE: field types are emitted by their fully-qualified paths, so (exactly
    # like JSON::Serializable) file-private types can't be used as field types.
    def initialize(*, __kebab_args args : Array(String))
      {% begin %}
              {%
                option_ivars = [] of Nil
                argument_ivars = [] of Nil
                subcommand_ivars = [] of Nil

                @type.instance_vars.each do |ivar|
                  if ivar.annotation(::Kebab::Ignore)
                    unless ivar.type.nilable? || ivar.has_default_value?
                      raise "@[Kebab::Ignore] field '#{ivar.name}' on #{@type} must be nilable or have a default value"
                    end
                  elsif ivar.annotation(::Kebab::Subcommand)
                    subcommand_ivars << ivar
                  elsif ivar.annotation(::Kebab::Argument)
                    if ivar.annotation(::Kebab::Option)
                      raise "'#{ivar.name}' on #{@type} can't be both an option and an argument"
                    end
                    argument_ivars << ivar
                  else
                    option_ivars << ivar
                  end
                end

                if subcommand_ivars.size > 1
                  raise "#{@type} can only have one @[Kebab::Subcommand] field"
                end

                if !subcommand_ivars.empty? && !argument_ivars.empty?
                  raise "#{@type} can't have both positional arguments and a subcommand"
                end

                short_ivars = option_ivars.select { |option_ivar| option_ivar.annotation(::Kebab::Option) && option_ivar.annotation(::Kebab::Option)[:short] }

                subcommand_ivar = subcommand_ivars.first
                if subcommand_ivar && subcommand_ivar.type.nilable?
                  raise "@[Kebab::Subcommand] field '#{subcommand_ivar.name}' on #{@type} can't be nilable — use `required: true/false` on the annotation instead"
                end

                subcommand_members = if subcommand_ivar
                                       subcommand_ivar.type.union? ? subcommand_ivar.type.union_types : [subcommand_ivar.type]
                                     else
                                       [] of Nil
                                     end
                subcommand_names = subcommand_members.map do |member|
                  (member.annotation(::Kebab::Command) && member.annotation(::Kebab::Command)[:name]) || member.name.stringify.split("::").last.underscore
                end
              %}

              {% for ivar in option_ivars + argument_ivars %}
                {% bases = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil } : [ivar.type] %}
                {% if bases.size != 1 %}
                  {% raise "Unsupported union type for '#{ivar.name}' on #{@type}: #{ivar.type}" %}
                {% end %}
                {% if bases.first == Bool && ivar.type.nilable? %}
                  {% raise "Flag '#{ivar.name}' on #{@type} can't be nilable — use `Bool = false`" %}
                {% end %}
                %value{ivar.name} : {{bases.first}}? = nil
              {% end %}

              {% if subcommand_ivar %}
                %value{subcommand_ivar.name} : ::Union({{subcommand_members.splat}}, ::Nil) = nil
              {% end %}

              %positionals = [] of String
              %separated = false
              %index = 0

              while %index < args.size
                %raw = args[%index]
                %token = %separated ? ::Kebab::Tokens::Positional.new(%raw).as(::Kebab::Token) : ::Kebab::Scanner.scan(%raw)

                case %token
                in ::Kebab::Tokens::Separator
                  %separated = true
                in ::Kebab::Tokens::Long
                  {% if option_ivars.empty? %}
                    __kebab_bail(::Kebab::Help.new(__kebab_help_text)) if %token.name == "help"
                    __kebab_bail(::Kebab::Error::UnknownOption.new(%token.to_s))
                  {% else %}
                    case %token.name
                    {% for ivar in option_ivars %}
                      {%
                        option = ivar.annotation(::Kebab::Option)
                        long = (option && option[:long]) || ivar.name.stringify.gsub(/_/, "-")
                        converter = option && option[:converter]
                        base = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil }.first : ivar.type
                      %}
                      when {{long}}
                        {% if base == Bool %}
                          if %inline = %token.value
                            __kebab_bail(::Kebab::Error::InvalidValue.new("--#{{{long}}}", %inline))
                          end
                          %value{ivar.name} = true
                        {% else %}
                          %raw_value = %token.value || __kebab_next_value(args, %index, %separated, "--#{{{long}}}").tap { %index += 1 }
                          {% if converter %}
                            %value{ivar.name} = __kebab_convert({{base}}, "--#{{{long}}}", %raw_value, converter: {{converter}})
                          {% else %}
                            %value{ivar.name} = __kebab_convert({{base}}, "--#{{{long}}}", %raw_value)
                          {% end %}
                        {% end %}
                    {% end %}
                    when "help"
                      __kebab_bail(::Kebab::Help.new(__kebab_help_text))
                    else
                      __kebab_bail(::Kebab::Error::UnknownOption.new(%token.to_s))
                    end
                  {% end %}
                in ::Kebab::Tokens::Shorts
                  %chars = %token.chars
                  %chars.each_char_with_index do |%char, %char_index|
                    %last_char = %char_index == %chars.size - 1
                    {% if short_ivars.empty? %}
                      __kebab_bail(::Kebab::Help.new(__kebab_help_text)) if %char == 'h'
                      __kebab_bail(::Kebab::Error::UnknownOption.new("-#{%char}"))
                    {% else %}
                      case %char
                      {% for ivar in short_ivars %}
                        {%
                          option = ivar.annotation(::Kebab::Option)
                          short = option[:short]
                          converter = option[:converter]
                          base = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil }.first : ivar.type
                        %}
                        when {{short}}
                          {% if base == Bool %}
                            if %last_char && (%inline = %token.value)
                              __kebab_bail(::Kebab::Error::InvalidValue.new("-#{{{short}}}", %inline))
                            end
                            %value{ivar.name} = true
                          {% else %}
                            __kebab_bail(::Kebab::Error::MissingValue.new("-#{{{short}}}")) unless %last_char

                            %raw_value = %token.value || __kebab_next_value(args, %index, %separated, "-#{{{short}}}").tap { %index += 1 }
                            {% if converter %}
                              %value{ivar.name} = __kebab_convert({{base}}, "-#{{{short}}}", %raw_value, converter: {{converter}})
                            {% else %}
                              %value{ivar.name} = __kebab_convert({{base}}, "-#{{{short}}}", %raw_value)
                            {% end %}
                          {% end %}
                      {% end %}
                      when 'h'
                        __kebab_bail(::Kebab::Help.new(__kebab_help_text))
                      else
                        __kebab_bail(::Kebab::Error::UnknownOption.new("-#{%char}"))
                      end
                    {% end %}
                  end
                in ::Kebab::Tokens::Positional
                  {% if subcommand_ivar %}
                    case %token.value
                    when "help"
                      __kebab_bail(::Kebab::Help.new(__kebab_help_text))
                    {% for member, member_index in subcommand_members %}
                      when {{subcommand_names[member_index]}}
                        case %subcommand = {{member}}.parse(args[(%index + 1)..])
                        when {{member}}
                          %value{subcommand_ivar.name} = %subcommand
                        when ::Kebab::Help
                          __kebab_bail(%subcommand)
                        when ::Kebab::Errors
                          __kebab_bail(%subcommand)
                        else
                          # Unreachable by {{member}}.parse's signature, but the
                          # compiler can't see that — branch defensively so the
                          # case has no silent fall-through.
                          raise "unreachable: #{%subcommand.class} from {{member}}.parse"
                        end

                        break
                    {% end %}
                    else
                      __kebab_bail(::Kebab::Error::UnknownCommand.new(%token.value, {{subcommand_names.sort}}))
                    end
                  {% else %}
                    %positionals << %token.value
                  {% end %}
                end

                %index += 1
              end

              {% for ivar, position in argument_ivars %}
                {%
                  argument = ivar.annotation(::Kebab::Argument)
                  argument_name = (argument && argument[:name]) || ivar.name.stringify.gsub(/_/, "-")
                  converter = argument && argument[:converter]
                  base = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil }.first : ivar.type
                %}
                if %positional{ivar.name} = %positionals[{{position}}]?
                  {% if converter %}
                    %value{ivar.name} = __kebab_convert({{base}}, {{argument_name}}, %positional{ivar.name}, converter: {{converter}})
                  {% else %}
                    %value{ivar.name} = __kebab_convert({{base}}, {{argument_name}}, %positional{ivar.name})
                  {% end %}
                end
              {% end %}

              if %extra = %positionals[{{argument_ivars.size}}]?
                __kebab_bail(::Kebab::Error::UnexpectedArgument.new(%extra))
              end

              {% if subcommand_ivar %}
                {% subcommand_annotation = subcommand_ivar.annotation(::Kebab::Subcommand) %}
                {% subcommand_required = !!(subcommand_annotation && subcommand_annotation[:required]) %}
                %assigned{subcommand_ivar.name} = %value{subcommand_ivar.name}
                if %assigned{subcommand_ivar.name}.nil?
                  {% if subcommand_required %}
                    __kebab_bail(::Kebab::Error::MissingCommand.new({{subcommand_names.sort}}))
                  {% else %}
                    __kebab_bail(::Kebab::Help.new(__kebab_help_text))
                  {% end %}
                end
                @{{subcommand_ivar.name}} = %assigned{subcommand_ivar.name}
              {% end %}

              {% for ivar in option_ivars + argument_ivars %}
                {%
                  option = ivar.annotation(::Kebab::Option)
                  argument = ivar.annotation(::Kebab::Argument)
                  base = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil }.first : ivar.type

                  display_name =
                    if argument
                      (argument[:name] || ivar.name.stringify.gsub(/_/, "-"))
                    else
                      "--#{((option && option[:long]) || ivar.name.stringify.gsub(/_/, "-")).id}"
                    end

                  missing_error = argument ? ::Kebab::Error::MissingArgument : ::Kebab::Error::MissingOption
                %}
                %assigned{ivar.name} = %value{ivar.name}
                @{{ivar.name}} =
                  if %assigned{ivar.name}.nil?
                    {% if ivar.has_default_value? %}
                      {{ivar.default_value}}
                    {% elsif base == Bool %}
                      false
                    {% elsif ivar.type.nilable? %}
                      nil
                    {% else %}
                      __kebab_bail({{missing_error}}.new({{display_name}}))
                    {% end %}
                  else
                    %assigned{ivar.name}
                  end
              {% end %}
            {% end %}
    end

    # Safe to call from inside `initialize` — the body only reads
    # macro-generated literals, no instance state.
    private def __kebab_help_text : String
      {% begin %}
        {%
          option_rows = [] of Nil
          argument_rows = [] of Nil
          command_rows = [] of Nil
          argument_names = [] of Nil
          has_subcommand = false

          @type.instance_vars.each do |ivar|
            if ivar.annotation(::Kebab::Ignore)
              # not part of the CLI surface
            elsif ivar.annotation(::Kebab::Subcommand)
              has_subcommand = true
              members = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil } : [ivar.type]
              members.each do |member|
                member_command = member.annotation(::Kebab::Command)
                member_name = (member_command && member_command[:name]) || member.name.stringify.split("::").last.underscore
                command_rows << {member_name, (member_command && member_command[:summary]) || ""}
              end
            elsif ivar.annotation(::Kebab::Argument)
              argument = ivar.annotation(::Kebab::Argument)
              argument_name = (argument && argument[:name]) || ivar.name.stringify.gsub(/_/, "-")
              argument_names << argument_name
              argument_rows << {"<#{argument_name.id}>", (argument && argument[:description]) || ""}
            else
              option = ivar.annotation(::Kebab::Option)
              long = (option && option[:long]) || ivar.name.stringify.gsub(/_/, "-")
              short = option && option[:short]
              base = ivar.type.union? ? ivar.type.union_types.reject { |union_type| union_type == Nil }.first : ivar.type

              left = short ? "-#{short.id}, --#{long.id}" : "    --#{long.id}"
              left = "#{left.id} <value>" unless base == Bool
              option_rows << {left, (option && option[:description]) || ""}
            end
          end

          option_rows << {"-h, --help", "Show this help"}
          unless command_rows.empty?
            command_rows << {"help", "Show this help"}
          end
          command_rows = command_rows.sort_by { |command_row| command_row[0] }

          command = @type.annotation(::Kebab::Command)
          command_name = (command && command[:name]) || @type.name.stringify.split("::").last.underscore
          summary = command && command[:summary]

          usage = "Usage: #{command_name.id} [options]"
          argument_names.each { |argument_name| usage = "#{usage.id} <#{argument_name.id}>" }

          if has_subcommand
            usage = "#{usage.id} <command>"
          end
        %}

        %rows = {{option_rows + argument_rows + command_rows}}
        %width = %rows.max_of(&.first.size) + 2

        ::String.build do |%io|
          %io << {{usage}}

          {% if summary %}
            %io << "\n\n" << {{summary}}
          {% end %}

          {% unless argument_rows.empty? %}
            %io << "\n\nArguments:"
            {{argument_rows}}.each do |(%left, %description)|
              %io << "\n  " << "#{%left.ljust(%width)}#{%description}".rstrip
            end
          {% end %}

          {% unless command_rows.empty? %}
            %io << "\n\nCommands:"
            {{command_rows}}.each do |(%left, %description)|
              %io << "\n  " << "#{%left.ljust(%width)}#{%description}".rstrip
            end
          {% end %}

          %io << "\n\nOptions:"
          {{option_rows}}.each do |(%left, %description)|
            %io << "\n  " << "#{%left.ljust(%width)}#{%description}".rstrip
          end

          %io << '\n'
        end
      {% end %}
    end

    # The one path out of `initialize` for any parse outcome other than the
    # successfully constructed struct. Wrapping in `Internal::ParseExit`
    # means `self.parse` only rescues this one class — every other exception
    # propagates for the caller to deal with.
    private def __kebab_bail(result : ::Kebab::Help | ::Kebab::Errors) : NoReturn
      raise ::Kebab::Internal::ParseExit.new(result)
    end

    private def __kebab_next_value(args : Array(String), index : Int32, separated : Bool, name : String) : String
      next_raw = args[index + 1]?
      if next_raw.nil? || (!separated && !::Kebab::Scanner.scan(next_raw).is_a?(::Kebab::Tokens::Positional))
        __kebab_bail(::Kebab::Error::MissingValue.new(name))
      end

      next_raw
    end

    private def __kebab_convert(type : T.class, name : String, raw : String) : T forall T
      __kebab_unwrap(type, name, raw, ::Kebab::Convert.parse(type, raw))
    end

    private def __kebab_convert(type : T.class, name : String, raw : String, converter) : T forall T
      __kebab_unwrap(type, name, raw, converter.parse(raw))
    end

    private def __kebab_unwrap(type : T.class, name : String, raw : String, result : T | ::Kebab::Error::Base) : T forall T
      case result
      when T
        result
      else
        # The convert protocol only ever returns T or a Kebab::Error::Base
        # subclass; the cast is safe.
        __kebab_bail(::Kebab::Error::InvalidValue.new(name, raw, result.as(::Kebab::Error::Base)))
      end
    end
  end
end
