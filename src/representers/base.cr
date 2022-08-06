module Tanda::CLI
  module Representers
    abstract class Base(T)
      def initialize(object : T)
        @object = object
      end

      abstract def display

      protected def display_with_padding(key : String, value)
        puts "    #{key}: #{value}"
      end

      private getter object : T
    end
  end
end
