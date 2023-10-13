require "./interface"

module TandaCLI
  module Error
    abstract class Base < Exception
      include Error::Interface

      def initialize(@error : String, @error_description : String?)
        super("#{error}: #{error_description}")
      end
    end
  end
end
