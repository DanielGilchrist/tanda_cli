module TandaCLI
  module Models
    class ShiftEdit
      record Break, id : Int32?, start : ::Time, finish : ::Time?, paid : Bool do
        def pretty : String
          finish = self.finish
          finish_string = finish ? Utils::Time.pretty_time(finish) : "(open)"

          "#{Utils::Time.pretty_time(start)} - #{finish_string}"
        end
      end
    end
  end
end
