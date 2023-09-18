require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class TimeWorked < Base
      include CLI::ClientBuilder

      def setup_
        @name = "time_worked"
        @summary = @description = "See how many hours you've worked"

        add_commands(Today.new, Week.new)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
