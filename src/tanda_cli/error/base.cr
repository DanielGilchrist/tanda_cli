require "./interface"

module TandaCLI
  module Error
    abstract class Base < Exception
      include Error::Interface

      def initialize(@error : String, @error_description : String? = nil)
        message = begin
          if @error_description
            "#{error}: #{error_description}"
          else
            @error
          end
        end

        super(message)
      end
    end
  end
end
