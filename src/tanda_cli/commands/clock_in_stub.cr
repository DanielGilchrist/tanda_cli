module TandaCLI
  module Commands
    # Keeps "clockin" in Main's cling-generated help while the real command is
    # kebab-based and intercepted in TandaCLI.main before cling runs.
    class ClockInStub < Base
      def setup_
        @name = "clockin"
        @summary = @description = "Clock in/out"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        ClockIn.execute(["--help"], context)
      end
    end
  end
end
