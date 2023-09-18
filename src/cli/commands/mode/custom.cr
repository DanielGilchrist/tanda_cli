require "../base"

module Tanda::CLI
  module CLI::Commands
    class Mode
      class Custom < Base
        def setup_
          @name = "custom"
          @summary = @description = "Set the app to run commands from a custom environment"

          add_argument "url", description: "The URL of the custom environment", required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          url = arguments.get("url").as_s

          Utils::Display.error!("Must pass an argument to custom") if url.blank?

          uri = Utils::URL.validate(url)

          Utils::Display.error!(uri.message, url) if uri.is_a?(Utils::URL::Error)

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
