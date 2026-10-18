require "./base"

module TandaCLI
  module Error
    class NoCurrentUser < Error::Base
      def initialize : Nil
        super(
          "No current user set!",
          "Run `tanda_cli current_user list` to see your options, then `tanda_cli current_user set <id or name>`.",
        )
      end
    end
  end
end
