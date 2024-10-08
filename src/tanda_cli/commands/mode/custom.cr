require "../base"

module TandaCLI
  module Commands
    class Mode
      class Custom < Base
        @disable_staging_warning = true

        def setup_
          @name = "custom"
          @summary = @description = "Set the app to run commands from a custom environment"

          add_argument "url", description: "The URL of the custom environment", required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          url = arguments.get("url").as_s

          Utils::Display.error!("Must pass an argument to custom") if url.blank?

          uri = Utils::URL.validate(url)
          Utils::Display.error!(uri) if uri.is_a?(Error::InvalidURL)

          uri_string = uri.to_s
          config = Current.config
          config.mode = uri_string
          config.save!

          Utils::Display.success("Successfully set custom url", uri_string)
        end
      end
    end
  end
end
