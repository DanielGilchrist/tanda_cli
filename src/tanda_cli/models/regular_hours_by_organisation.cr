require "./regular_hours_schedule"

module TandaCLI
  module Models
    alias RegularHoursByOrganisation = Hash(Int32, Array(RegularHoursSchedule))
  end
end
