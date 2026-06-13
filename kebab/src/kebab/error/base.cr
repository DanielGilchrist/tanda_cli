module Kebab
  module Error
    abstract class Base < Exception
      def initialize(@error : String, @error_description : String? = nil)
        message =
          if @error_description
            "#{@error}: #{@error_description}"
          else
            @error
          end

        super(message)
      end

      getter error : String
      getter error_description : String?
    end
  end
end
