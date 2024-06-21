module TandaCLI
  class Result(T, E)
    def initialize(@value : T | E); end

    def or(& : E -> U) : T | U forall U
      case value = @value
      in T
        value
      in E
        yield(value)
      end
    end
  end
end
