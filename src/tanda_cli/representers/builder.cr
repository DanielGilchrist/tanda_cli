module TandaCLI
  module Representers
    struct Builder
      @builder : String::Builder

      def initialize
        @builder = String::Builder.new
      end

      delegate :<<, to: @builder

      def pad_end(char : Char, n = 1)
        n.times do
          char.bytes.each do |byte|
            @builder.chomp!(byte)
          end
        end

        n.times { @builder << char }
      end

      def to_s(io)
        io << @builder.to_s
      end
    end
  end
end
