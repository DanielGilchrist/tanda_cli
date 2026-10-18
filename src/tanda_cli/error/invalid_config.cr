require "./base"

module TandaCLI
  module Error
    class InvalidConfig < Error::Base
      def initialize(path : String, reason : String? = nil) : Nil
        super(
          reason ? "Invalid config! #{reason}" : "Invalid config!",
          "Fix \"#{path}\" or delete it, then run the command again.",
        )
      end
    end
  end
end
