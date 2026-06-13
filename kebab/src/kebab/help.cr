module Kebab
  class Help
    def initialize(@text : String); end

    getter text : String

    def to_s(io : IO) : Nil
      io << @text
    end
  end
end
