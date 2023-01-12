module Tanda::CLI
  module Representers
    abstract class Base(T)
      DEFAULT_CAPACITY = 150

      def initialize(object : T)
        @object = object
      end

      def display
        result = build

        {% if flag?(:debug) %}
          puts "\n\n#{self.class.name} CAPACITY: #{result.size}\n\n"
        {% end %}

        puts result
      end

      def build
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
