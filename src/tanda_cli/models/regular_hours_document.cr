require "../error/invalid_regular_hours_document"
require "./regular_hours_document/problem"
require "./regular_hours_document/statement"
require "./regular_hours_week"

module TandaCLI
  module Models
    struct RegularHoursDocument
      HEADER = <<-HEADER
        # One line per day, days first. Save and quit to apply, quit without saving to cancel.
        #
        #   monday     8:30-17:00  break 30m           hours with an automatic break
        #   wednesday  8:30-17:00  break 10-10:15      hours with fixed break(s)
        #   friday     break none                      keep hours, drop the break
        #   saturday   off                             no shift
        #   sunday     same as saturday                copy a day
        #
        # Days: mon, mon-fri, mon,wed,fri, weekdays, weekend, all
        # Breaks: 30m (automatic), 12-12:30 (fixed), none
        HEADER

      BARE_DAY_PROBLEM = %(needs hours, "break ...", "off" or "same as <day>" after the day)

      def self.render(
        week : RegularHoursWeek,
        start_of_week : Time::DayOfWeek,
        title : String,
      ) : String
        String.build do |text|
          text << "# " << title << '\n'
          text << HEADER << "\n\n"
          week.days_in_order(start_of_week).each do |day_of_week|
            text << render_day(week, day_of_week) << '\n'
          end
        end
      end

      def self.parse(text : String) : RegularHoursDocument | Error::InvalidRegularHoursDocument
        statements = Array(Statement).new
        problems = Array(Problem).new

        text.each_line.with_index(1) do |raw, number|
          line = raw.partition('#').first.strip
          next if line.empty?

          case parsed = RegularHoursWeek::Edit.parse(line)
          in RegularHoursWeek::Edit::Any
            statements << Statement.new(number, line, parsed)
          in RegularHoursWeek::Edit::Prompt
            problems << Problem.new(number, line, BARE_DAY_PROBLEM)
          in Error::Base
            problems << Problem.new(number, line, parsed.error_description || parsed.error)
          end
        end

        return Error::InvalidRegularHoursDocument.new(problems) unless problems.empty?

        new(statements)
      end

      private def self.render_day(
        week : RegularHoursWeek,
        day_of_week : Time::DayOfWeek,
      ) : String
        name = day_of_week.to_s.downcase.ljust(9)
        schedule = week[day_of_week]
        return "#{name}  off" if schedule.nil?

        line = "#{name}  #{schedule.hours}"
        break_plan = schedule.break_plan
        return line if break_plan.is_a?(BreakPlan::None)

        "#{line}  break #{break_plan}"
      end

      def initialize(@statements : Array(Statement)) : Nil; end

      getter statements : Array(Statement)

      def empty? : Bool
        @statements.empty?
      end

      def apply_to(
        week : RegularHoursWeek,
      ) : RegularHoursWeek | Error::InvalidRegularHoursDocument
        mentioned = Set(Time::DayOfWeek).new

        @statements.each do |statement|
          mentioned.concat(statement.edit.days.days)

          case applied = week.apply(statement.edit)
          in RegularHoursWeek
            week = applied
          in Error::Base
            problem = Problem.new(statement.line, statement.text, applied.error)
            return Error::InvalidRegularHoursDocument.new([problem])
          end
        end

        week.keep_only(mentioned)
      end
    end
  end
end
