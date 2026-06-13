require "./base"
require "./unparseable"

module Kebab
  module Error
    class InvalidValue < Error::Base
      def initialize(name : String, value : String, cause : Unparseable? = nil)
        description =
          if cause
            "\"#{value}\" isn't a valid value for \"#{name}\" (#{cause.description})"
          else
            "\"#{value}\" isn't a valid value for \"#{name}\"."
          end

        super("Invalid value!", description)
      end
    end
  end
end
