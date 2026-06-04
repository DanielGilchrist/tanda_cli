module TandaCLI
  module Error
    module Interface
      abstract def error : String
      abstract def error_description : String?
    end
  end
end
