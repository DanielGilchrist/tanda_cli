require "../../client_builder"
require "../base"

module Tanda::CLI
  module CLI::Commands
    class RegularHours
      class Determine < Base
        include CLI::ClientBuilder

        def on_setup
          @name = "determine"
          @summary = @description = "Determine the regular hours for a user"
        end

        def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
          CLI::Executors::RegularHours::Determine.new(client).execute
        end
      end
    end
  end
end
