module TandaCLI
  module API
    enum Scope
      Me
      Roster
      Timesheet
      # Department
      # User
      # Cost
      # Leave
      # Unavailability
      # Datastream
      # Device
      # Qualifications
      # Settings
      Organisation
      # SMS
      Personal
      # Financial
      # Platform

      def to_api_name : String
        to_s.downcase
      end
    end
  end
end
