require "../../client_builder"
require "../base"

module Tanda::CLI
  module CLI::Commands
    class RegularHours
      class Determine < Base
        include CLI::ClientBuilder

        def setup_
          @name = "determine"
          @summary = @description = "Determine the regular hours for a user"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          CLI::Executors::RegularHours::Determine.new(client).execute
        end
      end
    end
  end
end
