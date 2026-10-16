require "./base"

module TandaCLI
  module Error
    class NoEditor < Error::Base
      def initialize : Nil
        super(
          "No editor configured",
          "Set $EDITOR or $VISUAL to edit regular hours in an editor.",
        )
      end
    end
  end
end
