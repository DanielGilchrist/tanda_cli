module TandaCLI
  module Representers
    abstract class Base(T)
      NEWLINE_BYTE = 10_u8

      def initialize(object : T)
        @object = object
      end

      def display(stdout : IO)
        stdout.puts build
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

      protected def with_padding(value : String, builder : String::Builder)
        builder << "    #{value}\n"
      end
    end
  end
end
