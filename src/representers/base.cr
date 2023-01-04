module Tanda::CLI
  module Representers
    abstract class Base(T)
      DEFAULT_CAPACITY = 1024

      def initialize(object : T)
        @object = object
        @builder = String::Builder.new(DEFAULT_CAPACITY)
      end

      def display
        build_display

        {% if flag?(:debug) %}
          puts "\n\n#{self.class.name} CAPACITY: #{builder.capacity}\n\n"
        {% end %}

        puts builder.to_s
      end

      private abstract def build_display

      protected def with_padding(key : String, value)
        builder << "    #{key}: #{value}\n"
      end

      private getter object : T
      private getter builder : String::Builder
    end
  end
end
