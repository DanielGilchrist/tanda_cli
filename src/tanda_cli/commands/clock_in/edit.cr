require "../../error/invalid_shift_choice"
require "../../models/shift_edit"
require "../../converters/day"
require "../helpers/clock_in_day"

module TandaCLI
  module Commands
    struct ClockIn
      @[Kebab::Command(summary: "Edit the clock ins for a day")]
      struct Edit
        include Kebab::Parseable
        include Helpers::ClockInDay

        @[Kebab::Option(short: 'd', converter: ::TandaCLI::Converters::Day, description: "Day to edit, defaults to today (\"wed\", \"yesterday\" or YYYY-MM-DD)")]
        getter date : Models::ClockInDay?

        HINT      = "Type a time like 8:30am. Enter keeps it, none clears it."
        CANCELLED = "Cancelled. Nothing submitted."

        def run(context : Context) : Nil
          display = context.display

          day = resolve_day(context)
          api_shifts = context.client.shifts.list(context.current.user.id, day).or { |error| display.error!(error) }
          shifts = api_shifts.compact_map { |api_shift| Models::WorkedShift.from?(api_shift) }
          pretty_day = Utils::Time.pretty_date(day)

          return display.puts "No clock ins recorded for #{pretty_day}. Use `clockin backfill` to add them." if shifts.empty?

          display.puts "📅 #{pretty_day.colorize.white.bold}"
          shift = choose_shift(context, shifts)
          edit = Models::ShiftEdit.new(shift)

          unless edit.breaks_editable?
            display.puts
            display.warning("This shift has breaks without times, so they can't be edited here")
          end

          show(display, edit)
          edit_until_done(context, edit)

          return display.puts "No changes made." unless edit.changed?

          if error = edit.validate
            display.error!(error)
          end

          return display.puts CANCELLED unless confirm?(context)

          submit(context, edit)
          display.success("Updated your shift for #{pretty_day}")
        end

        private def choose_shift(context : Context, shifts : Array(Models::WorkedShift)) : Models::WorkedShift
          return shifts.first if shifts.one?

          display = context.display
          display.puts
          display.puts "You have #{shifts.size} shifts on this day."
          shifts.each_with_index(1) do |shift, number|
            display.puts "  #{number.colorize.cyan}  #{shift.pretty_start_time || "none"} - #{shift.pretty_finish_time || "none"}"
          end
          display.puts

          prompt(context, "Which shift? 1-#{shifts.size} #{arrow}") do |answer|
            number = answer.to_i?
            next Error::InvalidShiftChoice.new(answer, shifts.size) if number.nil? || number < 1

            shifts[number - 1]? || Error::InvalidShiftChoice.new(answer, shifts.size)
          end || display.error!(CANCELLED)
        end

        private def show(display : TandaCLI::Display, edit : Models::ShiftEdit) : Nil
          display.puts
          edit.representer.display(display)
          display.puts
        end

        private def edit_until_done(context : Context, edit : Models::ShiftEdit) : Nil
          hinted = false

          loop do
            choice = prompt(context, menu(edit)) { |answer| edit.choose(answer) }
            return if choice.nil?

            context.display.puts "  #{HINT}" unless hinted
            hinted = true

            changed =
              case choice
              in Models::ShiftEdit::BreakChange
                edit_break(context, edit, choice)
              in Models::ShiftEdit::Field
                edit_field(context, edit, choice)
              end

            show(context.display, edit) if changed
          end
        end

        private def menu(edit : Models::ShiftEdit) : String
          range = "1-#{edit.targets.size}"
          options = edit.breaks_editable? ? "#{range}, b to add a break" : range

          "Edit which? #{options}, Enter when done #{arrow}"
        end

        private def edit_field(context : Context, edit : Models::ShiftEdit, target : Models::ShiftEdit::Field) : Bool
          case target
          in .start?
            prompt(context, field("Start", pretty(edit.start))) { |answer| edit.change_start(answer) }
            true
          in .finish?
            prompt(context, field("Finish", pretty(edit.finish))) { |answer| edit.change_finish(answer) }
            true
          in .new_break?
            add_break(context, edit)
          end
        end

        private def edit_break(context : Context, edit : Models::ShiftEdit, break_change : Models::ShiftEdit::BreakChange) : Bool
          index = break_change.index
          shift_break = break_change.shift_break
          start_label = "Break #{break_change.number} start"
          finish_label = "Break #{break_change.number} finish"
          start = pretty(shift_break.start)
          finish = pretty_break_finish(shift_break.finish)
          value_width = {start.size, finish.size}.max

          started = prompt(context, field(start_label, start, finish_label.size, value_width)) do |answer|
            next edit.remove_break(index) if answer.downcase == "none"

            edit.change_break_start(index, answer)
          end
          return true if started.is_a?(Models::ShiftEdit::Break)

          prompt(context, field(finish_label, finish, finish_label.size, value_width)) do |answer|
            edit.change_break_finish(index, answer)
          end
          true
        end

        private def add_break(context : Context, edit : Models::ShiftEdit) : Bool
          start_label = "New break start"
          finish_label = "New break finish"

          started = prompt(context, field(start_label, "skip", finish_label.size)) do |answer|
            edit.add_break(answer)
          end
          return false if started.nil?

          prompt(context, field(finish_label, "open", finish_label.size)) do |answer|
            edit.change_break_finish(edit.breaks.size - 1, answer)
          end
          true
        end

        private def prompt(context : Context, message : String, & : String -> T | Error::Base) : T? forall T
          loop do
            answer = context.input.ask(message)
            return if answer.nil?

            case parsed = yield(answer)
            in Error::Base
              context.display.error(parsed)
            in T
              return parsed
            end
          end
        end

        private def field(label : String, current : String, label_width : Int32 = label.size, value_width : Int32 = current.size) : String
          "  #{label.ljust(label_width)}  #{current.ljust(value_width)} #{arrow}"
        end

        private def arrow : String
          "#{"›".colorize.cyan} "
        end

        private def submit(context : Context, edit : Models::ShiftEdit) : Nil
          display = context.display
          client = context.client

          if edit.start_changed? || edit.finish_changed?
            client.shifts.update(edit.id) do |update|
              update.start(edit.start) if edit.start_changed?
              update.finish(edit.finish) if edit.finish_changed?
            end.or { |error| display.error!(error) }
          end

          edit.removed_breaks.each do |shift_break|
            break_id = shift_break.id
            next if break_id.nil?

            client.shift_breaks.update(edit.id, break_id) do |update|
              update.start(nil)
              update.finish(nil)
              update.length(0)
            end.or { |error| display.error!(error) }
          end

          edit.break_changes.select(&.changed?).each do |change|
            shift_break = change.shift_break

            if break_id = shift_break.id
              client.shift_breaks.update(edit.id, break_id) do |update|
                update.start(shift_break.start) if change.start_changed?
                update.finish(shift_break.finish) if change.finish_changed?
              end
            else
              client.shift_breaks.create(edit.id) do |update|
                update.start(shift_break.start)
                update.finish(shift_break.finish)
              end
            end.or { |error| display.error!(error) }
          end
        end

        private def pretty(time : ::Time?) : String
          time ? Utils::Time.pretty_time(time) : "none"
        end

        private def pretty_break_finish(time : ::Time?) : String
          time ? Utils::Time.pretty_time(time) : "open"
        end
      end
    end
  end
end
