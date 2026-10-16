require "../../error/unparseable_regular_hours_edit"
require "../break_plan"
require "../day_set"
require "../time_range"
require "./edit/*"

module TandaCLI
  module Models
    struct RegularHoursWeek
      module Edit
        alias Any = Hours | Break | Remove | Copy
        alias Parsed = Any | Prompt

        MERIDIEM_SPACING = /(\d)\s+([ap]\.?m?\.?)(?=\s|$)/i
        RANGE_SPACING    = /\s*-\s*/

        def self.parse(line : String) : Parsed | Error::Base
          words = normalise(line).split(' ', remove_empty: true)
          days_word = words.shift?
          return Error::UnparseableRegularHoursEdit.new(line) if days_word.nil?

          days = DaySet.parse(days_word)
          return days if days.is_a?(Error::Base)

          return Prompt.new(days) if words.empty?
          return Remove.new(days) if words == ["off"]
          return parse_copy(days, words) if words.size == 3 && words[0, 2] == ["same", "as"]

          parse_hours_or_break(line, days, words)
        end

        private def self.parse_copy(days : DaySet, words : Array(String)) : Copy | Error::Base
          from = ClockInDay.parse_day_of_week(words.last)
          return Error::UnparseableDaySet.new(words.last) if from.nil?

          Copy.new(days, from)
        end

        private def self.parse_hours_or_break(
          line : String,
          days : DaySet,
          words : Array(String),
        ) : Any | Error::Base
          if words.first == "break"
            break_plan = BreakPlan.parse(words[1..])
            return break_plan if break_plan.is_a?(Error::Base)

            return Break.new(days, break_plan)
          end

          hours = TimeRange.parse(words.first)
          return hours if hours.is_a?(Error::Base)

          rest = words[1..]
          return Hours.new(days, hours, nil) if rest.empty?
          return Error::UnparseableRegularHoursEdit.new(line) unless rest.first == "break"

          break_plan = BreakPlan.parse(rest[1..])
          return break_plan if break_plan.is_a?(Error::Base)

          Hours.new(days, hours, break_plan)
        end

        private def self.normalise(line : String) : String
          line.strip.downcase
            .gsub(MERIDIEM_SPACING, "\\1\\2")
            .gsub(RANGE_SPACING, "-")
            .squeeze(' ')
        end
      end
    end
  end
end
