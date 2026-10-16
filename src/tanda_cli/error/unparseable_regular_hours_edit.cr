require "./base"

module TandaCLI
  module Error
    class UnparseableRegularHoursEdit < Error::Base
      def initialize(line : String) : Nil
        super(
          "Unknown edit!",
          %("#{line}" doesn't look like an edit ) +
          %((try "fri 8:30-16 break 30m", "sat off" or "tue-fri same as mon").),
        )
      end
    end
  end
end
