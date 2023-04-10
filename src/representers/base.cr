module Tanda::CLI
  module Representers
    abstract class Base(T)
      NEWLINE_BYTE = 10_u8

      def initialize(object : T)
        @object = object
      end

      def display
        puts build
      end

      def build : String
        String.build do |builder|
          build_display(builder)
          builder.chomp!(NEWLINE_BYTE)
          builder.chomp!(NEWLINE_BYTE)
          builder << "\n\n"
        end
      end

      private abstract def build_display(builder : String::Builder)

      protected def with_padding(key : String, value, builder : String::Builder)
        builder << "    #{key}: #{value}\n"
      end

      private getter object : T
    end
  end
end
