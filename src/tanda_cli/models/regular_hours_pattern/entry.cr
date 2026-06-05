module TandaCLI
  module Models
    struct RegularHoursPattern
      struct Entry
        def initialize(
          @day_of_week : Time::DayOfWeek,
          @start_time : Time,
          @finish_time : Time,
          @automatic_break_length : Time::Span,
          @breaks : Array(Schedule::Break),
          @source_date : Time,
          @weeks_seen : Int32,
        ); end

        getter day_of_week : Time::DayOfWeek
        getter start_time : Time
        getter finish_time : Time
        getter automatic_break_length : Time::Span
        getter breaks : Array(Schedule::Break)
        getter source_date : Time
        getter weeks_seen : Int32

        def pretty_hours : String
          "#{Utils::Time.pretty_time(start_time)} - #{Utils::Time.pretty_time(finish_time)}"
        end

        def break_summary : String
          if breaks.empty?
            return "—" if automatic_break_length.zero?
            "#{automatic_break_length.total_minutes.to_i}min auto"
          elsif breaks.size == 1
            single = breaks.first
            "#{Utils::Time.pretty_time(single.start_time)} - #{Utils::Time.pretty_time(single.finish_time)}"
          else
            "#{breaks.size} breaks"
          end
        end
      end
    end
  end
end
