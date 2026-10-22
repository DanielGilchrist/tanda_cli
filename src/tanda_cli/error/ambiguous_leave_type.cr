require "./base"

module TandaCLI
  module Error
    class AmbiguousLeaveType < Error::Base
      def initialize(value : String, matches : Array(String)) : Nil
        super(
          "\"#{value}\" matches more than one leave type",
          "It could be: #{matches.join(", ")}"
        )
      end
    end
  end
end
