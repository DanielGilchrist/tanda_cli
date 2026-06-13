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

        def label : String
          case self
          in .start?
            "Clock in"
          in .finish?
            "Clock out"
          in .break_start?
            "Break start"
          in .break_finish?
            "Break finish"
          end
        end
      end
    end
  end
end
