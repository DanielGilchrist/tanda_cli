require "./base"
require "./table"
require "../api/types/leave_request"
require "../utils/duration"

module TandaCLI
  module Representers
    struct LeaveRequest < Base(API::Types::LeaveRequest)
      HOLIDAY_GUTTER = '·'
      HOURS_COLUMN   = 1
      LABEL_WIDTH    = 8

      private def build_display(builder : Builder) : Nil
        builder.puts(heading)
        builder.puts

        labelled(builder, "Dates", dates)
        labelled(builder, "Hours", Utils::Duration.compact(@object.hours))
        labelled(builder, "Times", times) unless @object.all_day?

        reason = @object.reason
        labelled(builder, "Reason", reason) if reason && !reason.blank?

        build_breakdown(builder)
      end

      private def heading : String
        "#{@object.leave_type.colorize.white.bold}  ##{@object.id}  #{@object.status}"
      end

      private def labelled(builder : Builder, label : String, value : String) : Nil
        builder.puts("  #{label.ljust(LABEL_WIDTH)}#{value}")
      end

      private def build_breakdown(builder : Builder) : Nil
        return if @object.daily_breakdown.empty?

        builder.puts

        table = Table.new([
          Table::Column.new("DATE"),
          Table::Column.new("HOURS", align: :right),
          Table::Column.new("NOTE"),
        ])

        @object.each do |breakdown|
          table << Table::Row.new(
            [
              Utils::Time.short_date(breakdown.date),
              Utils::Duration.compact(breakdown.hours),
              breakdown.holiday? ? "public holiday" : "",
            ],
            gutter: breakdown.holiday? ? HOLIDAY_GUTTER : ' '
          )
        end

        table.summarise(HOURS_COLUMN, Utils::Duration.compact(@object.hours), "") if @object.daily_breakdown.size > 1
        table.build(builder, header: false)
      end

      private def dates : String
        range = Utils::Time.date_range(@object.start, @object.finish)
        return range if @object.single_day?

        "#{range}  (#{@object.days} days, #{@object.daily_breakdown.size} working)"
      end

      private def times : String
        breakdown = @object.daily_breakdown.first?
        return "" if breakdown.nil?

        "#{breakdown.pretty_start_time || "?"} – #{breakdown.pretty_finish_time || "?"}"
      end
    end
  end
end
