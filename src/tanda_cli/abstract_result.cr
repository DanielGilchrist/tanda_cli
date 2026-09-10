module TandaCLI
  abstract struct AbstractResult(T, E)
    def initialize(@value : T | E) : Nil; end

    def or(& : E -> U) : T | U forall U
      case value = @value
      in T
        value
      in E
        yield(value)
      end
    end

    def unwrap! : T
      case value = @value
      in T
        value
      in E
        raise(value.error)
      end
    end
  end
end
