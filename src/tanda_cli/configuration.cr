require "json"
require "file_utils"

require "./configuration/**"
require "./error/invalid_start_of_week"
require "./types/access_token"
require "./utils/url"

module TandaCLI
  class Configuration
    PRODUCTION = "production"
    STAGING    = "staging"

    def self.init(file : Configuration::AbstractFile, display : Display) : Configuration
      config_contents = file.read
      return new(file) unless config_contents.presence

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
      :site_prefix,
      :site_prefix=,
      :access_token,
      :current_environment,
      :reset_environment!,
      :staging?,
      to: @serialisable

    def overwrite!(site_prefix : String, email : String, access_token : Types::AccessToken)
      self.site_prefix = site_prefix
      self.access_token.email = email
      self.access_token.token = access_token.token
      self.access_token.token_type = access_token.token_type
      self.access_token.scopes = access_token.scopes
      self.access_token.created_at = access_token.created_at

      save!
    end

    def save!
      @file.write(@serialisable.to_json)
    end

    def api_url : String | Error::InvalidURL
      case mode
      when PRODUCTION
        "https://#{site_prefix}.tanda.co/api/v2"
      when STAGING
        prefix = "#{site_prefix}." if site_prefix != "my"
        "https://staging.#{prefix}tanda.co/api/v2"
      else
        validated_uri = Utils::URL.validate(mode)
        return validated_uri if validated_uri.is_a?(Error::InvalidURL)

        "#{validated_uri}/api/v2"
      end
    end
  end
end
