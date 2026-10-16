require "./base"

module TandaCLI
  module Error
    class EmptyRegularHours < Error::Base
      def initialize : Nil
        super(
          "Nothing to save!",
          "Every day is off. Use `regular_hours clear` to remove regular hours.",
        )
      end
    end
  end
end
