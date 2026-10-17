require "./state/**"
require "./error/invalid_state"

module TandaCLI
  class State
    enum OAuthEndpoint
      Token
      Revoke

      def url(base_url : String) : String
        "#{base_url}/api/oauth/#{to_s.downcase}"
      end
    end

    def self.init(file : Storage::AbstractFile, display : Display) : State
      contents = file.read.presence
      return new(file) unless contents

      serialisable = Serialisable.parse?(contents)
      display.error!(Error::InvalidState.new(file.path)) if serialisable.nil?

      new(file, serialisable)
    end

    def initialize(@file : Storage::AbstractFile, @serialisable : Serialisable = Serialisable.new) : Nil; end

    delegate :current,
      :current_environment,
      :use_production!,
      :use_staging!,
      :use_custom!,
      :redacted,
      to: @serialisable

    delegate :access_token, :organisations, :organisations=, :current_organisation?, to: current

    def api_url : String
      "#{current.base_url}/api/v2"
    end

    def overwrite_access_token!(email : String, access_token : API::Types::AccessToken) : Nil
      current.access_token = Serialisable::AccessToken.from(email, access_token)
    end

    def clear! : Nil
      @serialisable.clear_current!
    end

    def save! : Nil
      @file.write(@serialisable)
    end
  end
end
