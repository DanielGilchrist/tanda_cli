require "term-prompt"

module TandaCLI
  module Scopes
    extend self

    enum Scope
      Me
      Roster
      Timesheet
      Leave
      Device
      Organisation
      Personal

      def to_api_name : String
        to_s.downcase
      end
    end

    def join_to_api_string(scopes : Array(Scope)) : String
      scopes.map(&.to_api_name).join(" ")
    end

    def prompt : Prompt
      Prompt.new
    end

    private class Prompt
      ALL = "All"

      def initialize
        @prompt = Term::Prompt.new
      end

      def multi_select(text : String) : Array(Scope)
        choices = @prompt.multi_select(text, scope_strings, min: 1).compact
        return Scope.values if choices.empty? || choices.includes?(ALL)

        choices.compact_map(&->Scope.parse?(String))
      end

      private def scope_strings : Array(String)
        [ALL] + Scope.names
      end
    end
  end
end
