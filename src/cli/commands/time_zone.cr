require "./base"

module Tanda::CLI
  module CLI::Commands
    class TimeZone < Base
      def setup_
        @name = "time_zone"
        @summary = @description = "See or set the current time zone"

        add_commands(TimeZone::Display.new, TimeZone::Set.new)
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        puts help_template
      end
    end
  end
end
