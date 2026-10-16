module TandaCLI
  module Models
    struct RegularHoursDocument
      record Statement, line : Int32, text : String, edit : RegularHoursWeek::Edit::Any
    end
  end
end
