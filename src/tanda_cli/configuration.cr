require "json"
require "file_utils"

require "./configuration/**"
require "./error/invalid_start_of_week"
require "./api/types/access_token"

module TandaCLI
  class Configuration
    enum OAuthEndpoint
      Token
      Revoke
    end

    def self.init(file : Configuration::AbstractFile, display : Display) : Configuration
      config_contents = file.read.presence
      return new(file) unless config_contents

      begin
        new(file, Serialisable.from_json(config_contents))
      rescue ex
        {% if flag?(:debug) %}
          raise(ex)
        {% else %}
          reason = ex.message.try(&.split("\n").first) if ex.is_a?(JSON::SerializableError) || ex.is_a?(JSON::ParseException)
          # TODO: Better handle this potential once-off case
          display.error("Invalid Config!", reason) do |sub_errors|
            sub_errors << "If you want to try and fix the config manually press Ctrl+C to quit\n"
            sub_errors << "Press enter if you want to proceed with a default config (this will override the existing config)"
          end
          gets # don't proceed unless user wants us to
          nil
        {% end %}
      end || new(file)
    end

    def initialize(@file : Configuration::AbstractFile, @serialisable = Serialisable.new); end

    delegate :current_organisation?, :current_organisation!, to: current_environment
    delegate :start_of_week,
      :start_of_week=,
      :pretty_start_of_week,
      :clockin_photo_path,
      :clockin_photo_path=,
      :mode,
      :mode=,
      :treat_paid_breaks_as_unpaid?,
      :organisations,
      :organisations=,
      :region,
      :region=,
      :access_token,
      :current_environment,
      :reset_environment!,
      to: @serialisable

    def overwrite!(region : Region, email : String, access_token : API::Types::AccessToken)
      self.region = region
      current_environment.access_token = Serialisable::AccessToken.from(email, access_token)

      save!
    end

    def save!
      @file.write(@serialisable.to_json)
    end

    def api_url : String
      build_url("api/v2")
    end

    def oauth_url(endpoint : OAuthEndpoint) : String
      build_url("api/oauth/#{endpoint.to_s.downcase}")
    end

    private def build_url(path_suffix : String) : String
      case current_mode = mode
      in Mode::Production
        "https://#{region.host(staging: false)}/#{path_suffix}"
      in Mode::Staging
        "https://#{region.host(staging: true)}/#{path_suffix}"
      in Mode::Custom
        "#{current_mode.url}/#{path_suffix}"
      end
    end
  end
end
