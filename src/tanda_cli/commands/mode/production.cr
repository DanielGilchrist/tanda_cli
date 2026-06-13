module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Set the app to run commands in production mode")]
      struct Production
        include Kebab::Parseable

        def run(context : Context) : Nil
          context.config.use_production!
          context.config.save!

          context.display.success("Successfully set mode to production!")
        end
      end
    end
  end
end
