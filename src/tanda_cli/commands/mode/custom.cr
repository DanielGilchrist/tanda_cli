module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Set the app to run commands from a custom environment")]
      struct Custom
        include Kebab::Parseable

        @[Kebab::Argument(description: "The URL of the custom environment")]
        getter url : String

        def run(context : Context) : Nil
          display = context.display

          display.error!("Must pass an argument to custom") if url.blank?

          case validated = Utils::URL.validate(url)
          in URI
            context.config.use_custom!(validated)
            context.config.save!
            display.success("Successfully set custom url", validated.to_s)
          in Error::InvalidURL
            display.error!(validated)
          end
        end
      end
    end
  end
end
