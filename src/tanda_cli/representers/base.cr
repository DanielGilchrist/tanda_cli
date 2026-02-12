module TandaCLI
  module Representers
    abstract struct Base(T)
      NEWLINE_BYTE = 10_u8

      def initialize(@object : T)
      end

      def display(display : Display)
        display.puts build.to_s
      end

      def build(builder : String::Builder = String::Builder.new) : String::Builder
        build_display(builder)
        builder.chomp!(NEWLINE_BYTE)
        builder.chomp!(NEWLINE_BYTE)
        builder << "\n\n"

        builder
      end

      private abstract def build_display(builder : String::Builder)

      protected def with_padding(value : String, builder : String::Builder)
        builder << "    #{value}\n"
      end
    end
  end
end
