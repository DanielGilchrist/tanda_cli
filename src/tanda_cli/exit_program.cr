module TandaCLI
  class ExitProgram < Exception
    SUCCESS = 0
    FAILURE = 1

    def initialize(@status : Int32 = SUCCESS) : Nil
      super()
    end

    getter status : Int32
  end
end
