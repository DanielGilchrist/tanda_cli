module TandaCLI
  module Commands
    module Helpers
      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end
    end
  end
end
