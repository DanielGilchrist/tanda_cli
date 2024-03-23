module TandaCLI
  module API
    enum Scope
      Me
      Roster
      Timesheet
      Leave
      Device
      Organisation
      Personal

      def to_api_name : String
        to_s.downcase
      end
    end
  end
end
