require "./base"

module TandaCLI
  module Error
    class InvalidURL < Error::Base
      def initialize(message : String, url : String) : Nil
        super(message, "#{url}")
      end
    end
  end
end
