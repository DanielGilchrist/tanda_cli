require "./base"

module TandaCLI
  module Error
    class InvalidState < Error::Base
      def initialize(path : String) : Nil
        super(
          "Invalid state!",
          "Delete \"#{path}\" and run `tanda_cli auth login` to authenticate again.",
        )
      end
    end
  end
end
