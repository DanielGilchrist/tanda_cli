require "./base"

module TandaCLI
  module Representers
    struct RegularHoursPattern < Base(Models::RegularHoursPattern)
      private record Row,
        day : String,
        hours : String,
        break_summary : String,
        seen : String

      private def build_display(builder : Builder)
        rows = @object.entries.map { |entry| build_row(entry) }

        day_width = max_width(rows.map(&.day), "Day")
        hours_width = max_width(rows.map(&.hours), "Hours")
        break_width = max_width(rows.map(&.break_summary), "Break")

        builder.puts heading
        builder.puts
        builder.puts column_header(day_width, hours_width, break_width)

        rows.each do |row|
          builder.puts "  #{row.day.ljust(day_width)}  #{row.hours.ljust(hours_width)}  #{row.break_summary.ljust(break_width)}  #{row.seen}"
        end
      end

      private def build_row(entry : Models::RegularHoursPattern::Entry) : Row
        Row.new(
          day: entry.day_of_week.to_s,
          hours: entry.pretty_hours,
          break_summary: entry.break_summary,
          seen: "#{entry.weeks_seen} of #{@object.weeks_probed}",
        )
      end

      private def heading : String
        week_word = @object.weeks_probed == 1 ? "week" : "weeks"
        "Suggested regular hours (#{@object.weeks_with_data} of #{@object.weeks_probed} #{week_word} had data):".colorize.white.bold.to_s
      end

      private def column_header(day_width : Int32, hours_width : Int32, break_width : Int32) : String
        "  #{"Day".ljust(day_width)}  #{"Hours".ljust(hours_width)}  #{"Break".ljust(break_width)}  Seen".colorize.white.bold.to_s
      end

      private def max_width(values : Array(String), header : String) : Int32
        (values + [header]).max_of(&.size)
      end
    end
  end
end
