module TandaCLI
  # Keeps one blank line between every question and block, and none before the first
  class Prompter
    def initialize(@input : Input, @display : Display) : Nil
      @printed = false
    end

    def ask(question : String) : String?
      space
      @input.ask_line("#{question} #{arrow}")
    end

    def lines(& : ->) : Nil
      space
      yield
    end

    private def space : Nil
      @display.puts if @printed
      @printed = true
    end

    private def arrow : String
      "#{"›".colorize.cyan} "
    end
  end
end
