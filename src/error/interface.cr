module Tanda::CLI
  module Error
    module Interface
      getter error : String
      getter error_description : String?

      def display
        Utils::Display.error(self)
      end

      def display! : NoReturn
        Utils::Display.error!(self)
      end
    end
  end
end
