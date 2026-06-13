module Kebab
  module Error
    abstract class Base
      def initialize(@error : String, @error_description : String? = nil)
      end

      getter error : String
      getter error_description : String?
    end
  end
end
