module TandaCLI
  module Commands
    module RequiredScopes
      @@required_scopes = [] of API::Scope

      macro included
        def self.required_scopes(*args : API::Scope)
          @@required_scopes.concat(args)
        end
      end

      def handle_required_scopes!
        return if @@required_scopes.empty?

        config = Current.config
        scopes = config.access_token.scope
        return if scopes.nil?

        if (missing_scopes = @@required_scopes - scopes).present?
          Utils::Display.error!("Missing scopes!") do |sub_errors|
            friendly_scopes = missing_scopes.map { |scope| "\"#{scope.to_api_name}\"" }.join(", ")
            sub_errors << "Need #{friendly_scopes} scopes for this command"
          end
        end
      end
    end
  end
end
