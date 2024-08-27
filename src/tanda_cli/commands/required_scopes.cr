module TandaCLI
  module Commands
    module RequiredScopes
      @@required_scopes = Array(Scopes::OptionalScope).new

      macro included
        def self.required_scopes(*args : Scopes::OptionalScope)
          @@required_scopes.concat(args)
        end
      end

      def handle_required_scopes!
        return if @@required_scopes.empty?

        config = Current.config
        scopes = config.access_token.scopes
        return if scopes.nil?

        missing_scopes = @@required_scopes - scopes
        return if missing_scopes.empty?

        Utils::Display.error("Missing scopes!") do |sub_errors|
          sub_errors << build_missing_scopes_error_message(missing_scopes)
          sub_errors << "\n"
        end

        config = Utils::Auth.maybe_refetch_token?("Do you want to refetch your token with new scopes?")
        Utils::Display.info!("Didn't refetch token") if config.nil?
      end

      def build_missing_scopes_error_message(scopes : Array(Scopes::OptionalScope)) : String
        scope_strings = scopes.map { |scope| "\"#{Scopes.to_api_name(scope)}\"" }
        scope_message = scope_message(scope_strings)

        "Need #{scope_message} for this command"
      end

      def scope_message(scope_strings : Array(String)) : String
        case scope_strings.size
        when 1
          "#{scope_strings.first} scope"
        when 2
          "#{scope_strings.join(" and ")} scopes"
        else
          "#{scope_strings[0..-2].join(", ") + " and " + scope_strings[-1]} scopes"
        end
      end
    end
  end
end
