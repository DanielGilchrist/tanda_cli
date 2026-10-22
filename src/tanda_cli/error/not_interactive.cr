require "./base"

module TandaCLI
  module Error
    class NotInteractive < Error::Base
      def initialize(what : String, remedy : String) : Nil
        super(what, "Stdin isn't a terminal. #{remedy}")
      end
    end
  end
end
