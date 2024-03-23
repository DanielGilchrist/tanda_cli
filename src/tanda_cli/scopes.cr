require "term-prompt"

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

    def prompt : Prompt
      Prompt.new
    end

    private class Prompt
      def initialize
        @prompt = Term::Prompt.new
      end

      def multi_select(text : String) : Array(Scope)
        choices = @prompt.multi_select(text, OptionalScope.names).compact
        return Scopes.all_scopes if choices.empty?

        with_required_scopes(Scopes.parse_strings_to_optional_scopes(choices))
      end

      private def with_required_scopes(scopes : Array(OptionalScope)) : Array(Scope)
        RequiredScope.values + scopes
      end
    end
  end
end
