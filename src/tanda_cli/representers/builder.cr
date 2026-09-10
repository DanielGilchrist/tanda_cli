module TandaCLI
  module Representers
    struct Builder
      @builder : String::Builder

      def initialize : Nil
        @builder = String::Builder.new
      end

      delegate :<<, to: @builder
      delegate :puts, to: @builder

      def to_s(io : IO) : Nil
        io << @builder.to_s
      end
    end
  end
end
