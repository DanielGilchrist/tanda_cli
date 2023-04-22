require "time"

struct Time
  def at_beginning_of_week(start_day : Time::DayOfWeek) : self
    start_day_num = start_day.value
    current_day_num = self.day_of_week.value
    difference = (current_day_num - start_day_num) % 7
    self - difference.days
  end
end
