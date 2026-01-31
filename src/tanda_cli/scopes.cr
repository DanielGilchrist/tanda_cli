require "term-prompt"
require "../ext/term_reader"
require "../ext/term_prompt"

module TandaCLI
  module Scopes
    extend self

    alias Scope = OptionalScope | RequiredScope

    enum OptionalScope
      Device
      Leave
      Personal
      Roster
      Timesheet
    end

    enum RequiredScope
      Me
    end

    def all_scopes : Array(Scope)
      RequiredScope.values + OptionalScope.values
    end

    def join_to_api_string(scopes : Array(Scope)) : String
      scopes.map(&->to_api_name(Scope)).join(" ")
    end

    def to_api_name(scope : Scope) : String
      scope.to_s.downcase
    end

    def parse_strings_to_scopes(scope_strings : Array(String)) : Array(Scope)
      scope_strings.compact_map(&->parse_string_to_scope?(String))
    end

    def parse_string_to_scope?(scope_string : String) : Scope?
      RequiredScope.parse?(scope_string) || OptionalScope.parse?(scope_string)
    end

    def parse_strings_to_optional_scopes(scope_strings : Array(String)) : Array(OptionalScope)
      scope_strings.compact_map(&->OptionalScope.parse?(String))
    end

    def prompt(stdin : IO, stdout : IO) : Prompt
      Prompt.new(stdin, stdout)
    end

    private class Prompt
      {% if flag?(:test) %}
        @prompt : TestPrompt
      {% else %}
        @prompt : Term::Prompt
      {% end %}

      def initialize(stdin : IO, stdout : IO)
        @prompt = {% if flag?(:test) %}
                    TestPrompt.new(stdin.as(IO::Memory), stdout.as(IO::Memory))
                  {% else %}
                    Term::Prompt.new(input: stdin.as(IO::FileDescriptor), output: stdout.as(IO::FileDescriptor))
                  {% end %}
      end

      def multi_select(text : String) : Array(Scope)
        choices = @prompt.multi_select(text, OptionalScope.names).compact
        return Scopes.all_scopes if choices.empty?

        with_required_scopes(Scopes.parse_strings_to_optional_scopes(choices))
      end

      private def with_required_scopes(scopes : Array(OptionalScope)) : Array(Scope)
        RequiredScope.values + scopes
      end

      {% if flag?(:test) %}
        private class TestPrompt
          def initialize(@stdin : IO::Memory, @stdout : IO::Memory)
          end

          def multi_select(text : String, choices : Array(String)) : Array(String)
            selected_choices = Array(String).new

            while line = @stdin.gets
              break if line == "_prompt_end_"

              line = line.strip
              next if line.empty?

              if line.to_i?.try { |i| i >= 0 && i < choices.size }
                # Line is a valid index
                selected_choices << choices[line.to_i]
              elsif choices.includes?(line)
                # Line is a valid choice name
                selected_choices << line
              end
            end

            selected_choices
          end
        end
      {% end %}
    end
  end
end
