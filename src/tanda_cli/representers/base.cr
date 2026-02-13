require "./builder"

module TandaCLI
  module Representers
    abstract struct Base(T)
      NEWLINE_BYTE = 10_u8

      def initialize(@object : T)
      end

      def display(display : Display)
        display.print build
      end

      def build(builder : Builder = Builder.new) : Builder
        builder.tap(&->build_display(Builder))
      end

      private abstract def build_display(builder : Builder)

      protected def with_padding(value : String, builder : Builder)
        builder << "    #{value}\n"
      end
    end
  end
end
