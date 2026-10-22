require "./base"
require "./leave/shared"
require "./table"
require "../api/types/leave_request"
require "../utils/duration"

module TandaCLI
  module Representers
    struct LeaveRequest < Base(API::Types::LeaveRequest)
      include Leave::Shared

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

      private def build_breakdown(builder : Builder) : Nil
        return if @object.daily_breakdown.empty?

        builder.puts

        table = breakdown_table

        @object.each do |breakdown|
          table << Table::Row.new(
            [
              Utils::Time.short_date(breakdown.date),
              breakdown.hours.zero? ? NOTHING : Utils::Duration.compact(breakdown.hours),
              breakdown.holiday? ? HOLIDAY_NOTE : "",
            ],
            gutter: breakdown.holiday? ? HOLIDAY_GUTTER : ' '
          )
        end

        table.summarise(HOURS_COLUMN, Utils::Duration.compact(@object.hours), pretty_deducted(deducted_days, @object.daily_breakdown.size)) if @object.daily_breakdown.size > 1
        table.build(builder, header: false)
      end

      private def dates : String
        range = Utils::Time.date_range(@object.start, @object.finish)
        return range if @object.single_day?

        "#{range}  (#{@object.days} days, #{deducted_days} deducted)"
      end

      private def deducted_days : Int32
        @object.daily_breakdown.count { |breakdown| !breakdown.hours.zero? }
      end

      private def times : String
        breakdown = @object.daily_breakdown.first?
        return "" if breakdown.nil?

        "#{breakdown.pretty_start_time || "?"} – #{breakdown.pretty_finish_time || "?"}"
      end
    end
  end
end
