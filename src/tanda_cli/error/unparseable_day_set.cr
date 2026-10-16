require "./base"

module TandaCLI
  module Error
    class UnparseableDaySet < Error::Base
      def initialize(value : String) : Nil
        super(
          "Unable to parse days!",
          %("#{value}" doesn't look like a day ) +
          %((try "mon", "mon-fri", "mon,wed,fri", "weekdays", "weekend" or "all").),
        )
      end
    end
  end
end
