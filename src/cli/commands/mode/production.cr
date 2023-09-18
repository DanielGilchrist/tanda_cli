require "../base"

module Tanda::CLI
  module CLI::Commands
    class Mode
      class Production < Base
        def on_setup
          @name = "production"
          @summary = @description = "Set the app to run commands in production mode"
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config = Current.config
          config.mode = "production"
          config.save!

          Utils::Display.success("Successfully set mode to production!")
        end
      end
    end
  end
end
