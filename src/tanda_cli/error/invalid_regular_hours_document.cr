require "./base"

module TandaCLI
  module Error
    class InvalidRegularHoursDocument < Error::Base
      def initialize(@problems : Array(Models::RegularHoursDocument::Problem)) : Nil
        word = @problems.one? ? "problem" : "problems"
        super(
          "Regular hours couldn't be read, #{@problems.size} #{word}:",
          @problems.join("\n"),
        )
      end

      getter problems : Array(Models::RegularHoursDocument::Problem)

      def as_comments : String
        @problems.join("\n") { |problem| "# error: #{problem}" }
      end
    end
  end
end
