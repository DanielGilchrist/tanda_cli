module Tanda::CLI
  class CLI::Parser
    abstract class BaseParser(T)
      @subject : T? = nil

      def initialize(@parser : OptionParser, @subject_builder : -> T); end

      abstract def parse

      private getter parser : OptionParser

      private def subject : T
        @subject ||= @subject_builder.call
      end
    end
  end
end
