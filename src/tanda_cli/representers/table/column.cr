module TandaCLI
  module Representers
    struct Table
      struct Column
        ELLIPSIS = '…'

        def initialize(@name : String, @align : Align = :left, @max_width : Int32? = nil) : Nil; end

        enum Align
          Left
          Right
        end

        getter name : String
        getter align : Align

        def width_for(cells : Array(String)) : Int32
          widest = cells.max_of?(&.size) || 0
          width = {widest, name.size}.max

          max_width = @max_width
          max_width ? {width, max_width}.min : width
        end

        def render(value : String, width : Int32) : String
          truncated = truncate(value, width)

          @align.right? ? truncated.rjust(width) : truncated.ljust(width)
        end

        def truncate(value : String, width : Int32) : String
          return value if value.size <= width
          return value[0, width] if width < 2

          "#{value[0, width - 1]}#{ELLIPSIS}"
        end
      end
    end
  end
end
