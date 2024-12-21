require "../base"

module TandaCLI
  module Commands
    class Mode
      class Production < Base
        @disable_staging_warning = true

        def setup_
          @name = "production"
          @summary = @description = "Set the app to run commands in production mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config.mode = "production"
          config.save!

          Utils::Display.success("Successfully set mode to production!", io: io)
        end
      end
    end
  end
end
