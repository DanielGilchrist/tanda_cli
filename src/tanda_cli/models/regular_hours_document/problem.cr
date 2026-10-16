module TandaCLI
  module Models
    struct RegularHoursDocument
      record Problem, line : Int32, text : String, message : String do
        def to_s(io : IO) : Nil
          io << "line " << line << ": " << message << " (" << text << ')'
        end
      end
    end
  end
end
