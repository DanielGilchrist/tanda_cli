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

        Utils::Display.error!("Missing scopes!") do |sub_errors|
          friendly_scopes = missing_scopes.map { |scope| "\"#{Scopes.to_api_name(scope)}\"" }.join(", ")
          sub_errors << "Need #{friendly_scopes} scopes for this command"
        end
      end
    end
  end
end
