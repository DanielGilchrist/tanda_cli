require "./base"

module TandaCLI
  module Error
    class BackwardsLeaveWindow < Error::Base
      def initialize(from : String, to : String) : Nil
        super(
          "That leave period finishes before it starts!",
          "#{from} comes after #{to}"
        )
      end
    end
  end
end
