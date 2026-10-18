require "./base"

module TandaCLI
  module Error
    class NotAuthenticated < Error::Base
      def initialize : Nil
        super(
          "Not authenticated!",
          "Run `tanda_cli auth login` to authenticate.",
        )
      end
    end
  end
end
