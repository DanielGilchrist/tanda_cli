require "../../editor"
require "../../error/empty_regular_hours"
require "../../error/no_editor"
require "../../models/regular_hours_document"
require "../../models/regular_hours_week"

module TandaCLI
  module Commands
    module Helpers
      module RegularHoursEditing
        HINT = %(e.g. "fri 8:30-16 break 30m", "sat off", "tue-fri same as mon") +
               %(  (? help, e edit in $EDITOR))

        HELP = <<-HELP
          Edits are one line, days first:
            fri 8:30-16 break 30m        hours, with an automatic break
            wed break 10-10:15 12-12:30  just the break(s)
            fri break none               drop the break
            sat off                      no shift
            tue-fri same as mon          copy a day
            fri                          prompt for hours and break

          Days    mon, mon-fri, mon,wed,fri, weekdays, weekend, all
          Breaks  30m (automatic), 12-12:30 (fixed), none

          Enter saves, n discards, show reprints the table, e opens the week in $EDITOR.
          HELP

        private def edit_loop(
          context : Context,
          week : Models::RegularHoursWeek,
          against : Models::RegularHoursWeek,
          prompt : String,
        ) : Models::RegularHoursWeek?
          display = context.display
          start_of_week = context.config.start_of_week

          display.puts HINT

          loop do
            line = context.input.read_line(prompt)
            return if line.nil?

            case line.strip.downcase
            when "", "y", "yes"
              return week
            when "n", "no"
              return
            when "?", "help"
              display.puts HELP
            when "show"
              week.representer(start_of_week, week.changes_from(against)).display(display)
            when "e", "edit"
              week = revise_in_editor(context, week, against) || week
            else
              week = apply_line(context, week, against, line) || week
            end
          end
        end

        private def apply_line(
          context : Context,
          week : Models::RegularHoursWeek,
          against : Models::RegularHoursWeek,
          line : String,
        ) : Models::RegularHoursWeek?
          display = context.display

          edited =
            case parsed = Models::RegularHoursWeek::Edit.parse(line)
            in Models::RegularHoursWeek::Edit::Prompt
              prompt_for_days(context, week, parsed.days)
            in Models::RegularHoursWeek::Edit::Any
              week.apply(parsed)
            in Error::Base
              parsed
            end

          case edited
          in Models::RegularHoursWeek
            show_changes(context, edited, from: week, against: against)
            edited
          in Error::Base
            display.error(edited)
            nil
          in Nil
            nil
          end
        end

        private def prompt_for_days(
          context : Context,
          week : Models::RegularHoursWeek,
          days : Models::DaySet,
        ) : (Models::RegularHoursWeek | Error::Base)?
          current = days.days.compact_map { |day_of_week| week[day_of_week] }.first?
          current_hours = current.try(&.hours) || "off"

          hours_message = "🕐 #{days} hours [#{current_hours}]:"
          hours = prompt_until_parsed(context, hours_message) do |answer|
            if answer.in?("off", "none")
              Models::RegularHoursWeek::Edit::Remove.new(days)
            else
              Models::TimeRange.parse(answer)
            end
          end

          case hours
          in Nil
            return current.nil? ? nil : week
          in Models::RegularHoursWeek::Edit::Remove
            return week.apply(hours)
          in Models::TimeRange
          end

          current_plan = current.try(&.break_plan)
          break_message = "☕ #{days} break [#{current_plan || "none"}]:"
          break_plan = prompt_until_parsed(context, break_message) do |answer|
            Models::BreakPlan.parse(answer.split(' '))
          end

          week.apply(
            Models::RegularHoursWeek::Edit::Hours.new(days, hours, break_plan || current_plan)
          )
        end

        private def prompt_until_parsed(
          context : Context,
          message : String,
          & : String -> T | Error::Base
        ) : T? forall T
          loop do
            answer = context.input.read_line(message).presence
            return if answer.nil?

            case parsed = yield(answer.strip.downcase)
            in Error::Base
              context.display.error(parsed)
            in T
              return parsed
            end
          end
        end

        private def show_changes(
          context : Context,
          week : Models::RegularHoursWeek,
          from : Models::RegularHoursWeek,
          against : Models::RegularHoursWeek,
        ) : Nil
          display = context.display
          changed = week.changes_from(from)

          marked = week.changes_from(against) | changed
          week
            .representer(context.config.start_of_week, marked, only_changed: true)
            .display(display)
          warn_overnight(display, week, changed)
        end

        private def warn_overnight(
          display : Display,
          week : Models::RegularHoursWeek,
          days : Array(Time::DayOfWeek),
        ) : Nil
          days.each do |day_of_week|
            schedule = week[day_of_week]
            next if schedule.nil?

            hours = schedule.hours
            next unless hours.length > Models::RegularHoursSchedule::OVERNIGHT_WARNING_LENGTH

            suggested_finish = Models::TimeOfDay.from(hours.finish.to_storage_time + 12.hours)
            length_hours = hours.length.total_hours.to_i
            suggestion = "Did you mean #{hours.start}-#{suggested_finish}?"
            display.warning("#{day_of_week} is #{length_hours} hours long. #{suggestion}")
          end
        end

        private def revise_in_editor(
          context : Context,
          week : Models::RegularHoursWeek,
          against : Models::RegularHoursWeek,
        ) : Models::RegularHoursWeek?
          display = context.display
          editor = Editor.from_environment
          return display.error(Error::NoEditor.new) if editor.nil?

          title = "Regular hours for #{context.current_organisation!.name}"
          text = Models::RegularHoursDocument.render(week, context.config.start_of_week, title)

          loop do
            case content = editor.edit(text)
            in Error::EditorFailed
              return display.error(content)
            in String
              case revised = revise_from(week, content)
              in Models::RegularHoursWeek
                show_changes(context, revised, from: week, against: against)
                return revised
              in Error::InvalidRegularHoursDocument
                display.error(revised)
                return unless edit_again?(context)

                kept = content.lines.reject(&.starts_with?("# error:")).join('\n')
                text = "#{revised.as_comments}\n#{kept}"
              in Nil
                return display.warning("No changes made")
              end
            end
          end
        end

        private def edit_again?(context : Context) : Bool
          answer = context.input.read_line("Edit again? (Y/n)")
          !answer.nil? && answer.strip.downcase.in?("", "y", "yes")
        end

        private def revise_from(
          week : Models::RegularHoursWeek,
          content : String,
        ) : (Models::RegularHoursWeek | Error::InvalidRegularHoursDocument)?
          case document = Models::RegularHoursDocument.parse(content)
          in Models::RegularHoursDocument
            return if document.empty?

            document.apply_to(week)
          in Error::InvalidRegularHoursDocument
            document
          end
        end

        private def save_week(context : Context, week : Models::RegularHoursWeek) : Nil
          display = context.display
          display.error!(Error::EmptyRegularHours.new) if week.empty?

          organisation = context.current_organisation!
          organisation.replace_regular_hours_schedules!(week.to_schedules)
          context.config.save!

          display.success("Regular hours set for #{organisation.name}")
        end
      end
    end
  end
end
