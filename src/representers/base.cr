module Tanda::CLI
  module Representers
    abstract class Base(T)
      def initialize(object : T)
        @object = object
      end

      def display
        puts build
      end

      def build : String
        String.build do |builder|
          build_display(builder)
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
