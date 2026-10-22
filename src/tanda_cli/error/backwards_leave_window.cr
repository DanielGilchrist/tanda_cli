require "./base"

module TandaCLI
  module Error
    class BackwardsLeaveWindow < Error::Base
      def initialize(from : Time, to : Time) : Nil
        super(
          "That leave period finishes before it starts",
          "#{Utils::Time.pretty_short_date(to)} comes before #{Utils::Time.pretty_short_date(from)}"
        )
      end
    end
  end
end
