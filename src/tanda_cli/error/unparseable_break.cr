require "./base"

module TandaCLI
  module Error
    class UnparseableBreak < Error::Base
      def initialize(value : String) : Nil
        super(
          "Unable to parse break!",
          %("#{value}" isn't a break. ) +
          %(Use minutes with a unit ("30m"), a range ("12-12:30") or "none".),
        )
      end
    end
  end
end
