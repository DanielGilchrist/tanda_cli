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

          case validated = Utils::URL.validate(url)
          in URI
            config.use_custom!(validated)
            config.save!
            display.success("Successfully set custom url", validated.to_s)
          in Error::InvalidURL
            display.error!(validated)
          end
        end
      end
    end
  end
end
