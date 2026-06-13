require "./base"

module Kebab
  module Error
    class InvalidValue < Error::Base
      def initialize(@reason : String, @option : String? = nil, @value : String? = nil)
        description =
          if (option = @option) && (value = @value)
            "\"#{value}\" isn't a valid value for \"#{option}\" (#{@reason})"
          else
            @reason
          end

        super("Invalid value!", description)
      end

      getter reason : String
      getter option : String?
      getter value : String?

      def with(option : String, value : String) : InvalidValue
        InvalidValue.new(reason: @reason, option: option, value: value)
      end
    end
  end
end
