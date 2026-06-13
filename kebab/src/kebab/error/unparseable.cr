module Kebab
  module Error
    class Unparseable
      def initialize(@description : String); end

      getter description : String
    end
  end
end
