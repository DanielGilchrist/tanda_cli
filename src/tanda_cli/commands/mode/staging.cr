module TandaCLI
  module Commands
    struct Mode
      @[Kebab::Command(summary: "Set the app to run commands in staging mode")]
      struct Staging
        include Kebab::Parseable

        def run(context : Context) : Nil
          context.state.use_staging!
          context.state.save!

          context.display.success("Successfully set mode to staging!")
        end
      end
    end
  end
end
