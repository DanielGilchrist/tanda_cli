require "./base"

module Kebab
  module Error
    class InvalidValue < Error::Base
      def initialize(name : String, value : String, cause : Error::Base? = nil)
        description =
          if cause
            "\"#{value}\" isn't a valid value for \"#{name}\" (#{cause.error_description || cause.error})"
          else
            "\"#{value}\" isn't a valid value for \"#{name}\"."
          end

        super("Invalid value!", description)
      end
    end
  end
end
