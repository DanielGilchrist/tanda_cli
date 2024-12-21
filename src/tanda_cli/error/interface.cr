module TandaCLI
  module Error
    module Interface
      getter error : String
      getter error_description : String?

      def display!(io) : NoReturn
        Utils::Display.error!(self, io)
      end
    end
  end
end
