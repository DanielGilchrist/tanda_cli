module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Set the app to run commands in staging mode")]
      struct Staging
        include Kebab::Parseable

        def run(context : Context) : Nil
          context.config.use_staging!
          context.config.save!

          context.display.success("Successfully set mode to staging!")
        end
      end
    end
  end
end
