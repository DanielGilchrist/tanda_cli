module Tanda::CLI
  module Representers
    abstract class Base(T)
      def initialize(object : T)
        @object = object
      end

      abstract def display

      private getter object : T
    end
  end
end
