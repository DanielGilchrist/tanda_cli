module TandaCLI
  module Error
    class InvalidURL < Error::Base
      def initialize(message : String, url : String)
        super(message, "#{url}")
      end
    end
  end
end
