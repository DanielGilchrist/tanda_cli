require "./base"

module TandaCLI
  module Representers
    struct RegularHoursWeek < Base(Models::RegularHoursWeek)
      private record Row,
        day_of_week : Time::DayOfWeek,
        hours : String,
        break_summary : String,
        worked : String

      alias Widths = NamedTuple(day: Int32, hours: Int32, breaks: Int32)

      OVERNIGHT_MARKER         = " (overnight)"
      OVERNIGHT_WARNING_LENGTH = Models::RegularHoursSchedule::OVERNIGHT_WARNING_LENGTH
      ABSENT                   = "—"

      def initialize(
        week : Models::RegularHoursWeek,
        @start_of_week : Time::DayOfWeek,
        @changed : Array(Time::DayOfWeek) = Array(Time::DayOfWeek).new,
        @only_changed : Bool = false,
      ) : Nil
        super(week)
      end

      private def build_display(builder : Builder) : Nil
        rows = @object.days_in_order(@start_of_week).map { |day| build_row(day) }
        widths = {
          day:    width_of(rows.map(&.day_of_week.to_s), "Day"),
          hours:  width_of(rows.map(&.hours), "Hours"),
          breaks: width_of(rows.map(&.break_summary), "Break"),
        }

        builder.puts header(widths).colorize.white.bold.to_s unless @only_changed

        rows.each do |row|
          next if @only_changed && !@changed.includes?(row.day_of_week)

          builder.puts line(row, widths)
        end

        builder.puts "#{" " * (widths.values.sum + 9)}#{pretty_total}"
      end

      private def header(widths : Widths) : String
        columns = [
          "Day".ljust(widths[:day]),
          "Hours".ljust(widths[:hours]),
          "Break".ljust(widths[:breaks]),
          "Worked",
        ]
        "   #{columns.join("  ")}"
      end

      private def line(row : Row, widths : Widths) : String
        columns = [
          row.day_of_week.to_s.ljust(widths[:day]),
          row.hours.ljust(widths[:hours]),
          row.break_summary.ljust(widths[:breaks]),
          row.worked,
        ]
        " #{marker(row)} #{columns.join("  ")}"
      end

      private def build_row(day_of_week : Time::DayOfWeek) : Row
        schedule = @object[day_of_week]
        return Row.new(day_of_week, ABSENT, ABSENT, ABSENT) if schedule.nil?

        hours = schedule.hours
        pretty_hours = hours.pretty
        pretty_hours += OVERNIGHT_MARKER if hours.length > OVERNIGHT_WARNING_LENGTH

        Row.new(day_of_week, pretty_hours, schedule.break_plan.pretty, schedule.pretty_worked)
      end

      private def marker(row : Row) : String
        return " " unless @changed.includes?(row.day_of_week)

        "*".colorize.yellow.to_s
      end

      private def pretty_total : String
        total = @object.total_worked
        "#{total.total_hours.to_i}h #{total.minutes.to_s.rjust(2, '0')}m"
      end

      private def width_of(values : Array(String), header : String) : Int32
        (values + [header]).max_of(&.size)
      end
    end
  end
end
