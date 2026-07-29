module TandaCLI
  module Models
    # How long a break lasted and how much we actually know about it
    module BreakLength
      module Measured
        macro included
          getter span : Time::Span

          def initialize(@span : Time::Span); end
        end
      end

      # The break finished
      struct Recorded
        include Measured
      end

      # The break is still running
      struct Running
        include Measured
      end

      # The break was never finished, so regular hours tell us how long it probably was
      struct Assumed
        include Measured
      end

      # The break was never finished and there are no regular hours to fall back on
      struct Unknown
        def span : Time::Span
          Time::Span.zero
        end
      end

      alias Any = Recorded | Running | Assumed | Unknown
    end
  end
end
