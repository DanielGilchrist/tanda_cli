require "../base"

module TandaCLI
  module Commands
    class Mode
      class Staging < Base
        @disable_staging_warning = true

        def setup_
          @name = "staging"
          @summary = @description = "Set the app to run commands in staging mode"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config = Current.config
          config.mode = "staging"
          config.save!

          Utils::Display.success("Successfully set mode to staging!")
        end
      end
    end
  end
end
