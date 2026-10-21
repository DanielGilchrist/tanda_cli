module TandaCLI
  module Representers
    struct Table
      struct Row
        def initialize(@cells : Array(String), @gutter : Char = ' ') : Nil; end

        getter cells : Array(String)
        getter gutter : Char

        def cell(index : Int32) : String
          @cells[index]? || ""
        end
      end
    end
  end
end
