require "../convert/failure"
require "./base"

module Kebab
  module Error
    class InvalidValue < Error::Base
      def self.from(failure : ::Kebab::Convert::Failure, *, value : String, option : String, target_type : Class) : self
        new(
          value: value,
          option: option,
          target_type_name: target_type.name,
          target_name: failure.name,
          reason: failure.reason,
        )
      end

      def initialize(
        @value : String,
        @option : String,
        @target_type_name : String,
        @target_name : String? = nil,
        @reason : String? = nil,
      )
        super(build_message)
      end

      getter value : String
      getter option : String
      getter target_type_name : String
      getter target_name : String?
      getter reason : String?

      def of?(klass : Class) : Bool
        klass.name == @target_type_name
      end

      private def build_message : String
        message = "\"#{@value}\" isn't a valid #{noun} for \"#{@option}\""
        message += " (#{@reason})" if @reason
        message
      end

      private def noun : String
        @target_name || @target_type_name
      end
    end
  end
end
