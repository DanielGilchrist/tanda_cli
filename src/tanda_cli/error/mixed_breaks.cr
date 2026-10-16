require "./base"

module TandaCLI
  module Error
    class MixedBreaks < Error::Base
      def initialize : Nil
        super(
          "Unable to parse break!",
          %(Use either an automatic length ("30m") or fixed ranges ("12-12:30"), not both.),
        )
      end
    end
  end
end
