require "../base"

module TandaCLI
  module Commands
    class Mode
      class Custom < Base
        disable_staging_warning!

        def setup_
          @name = "custom"
          @summary = @description = "Set the app to run commands from a custom environment"

          add_argument "url", description: "The URL of the custom environment", required: true
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          url = arguments.get("url").as_s
          display.error!("Must pass an argument to custom") if url.blank?

          case parsed = Configuration::Mode.from_string(url)
          in Configuration::Mode::Custom
            config.mode = parsed
            config.save!
            display.success("Successfully set custom url", parsed.url.to_s)
          in Configuration::Mode::Production, Configuration::Mode::Staging
            display.error!("Use the dedicated subcommand for #{parsed.display_label}, not custom")
          in Error::InvalidURL
            display.error!(parsed)
          end
        end
      end
    end
  end
end
