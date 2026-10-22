require "./base"
require "./table"
require "../models/leave_draft"
require "../utils/duration"

module TandaCLI
  module Representers
    struct LeaveDraft < Base(Models::LeaveDraft)
      HOLIDAY_GUTTER = '·'
      NOTHING        = "– "
      HOLIDAY_NOTE   = "public holiday"
      HOURS_COLUMN   = 1
      LABEL_WIDTH    = 9

      def initialize(
        object : T,
        @holidays : Array(API::Types::LeaveRequest) = Array(API::Types::LeaveRequest).new,
        @balance : API::Types::LeaveBalance? = nil,
        @breakdown : Models::LeaveBreakdown::Any? = nil,
        @day_length : Time::Span? = nil,
      ) : Nil
        super(object)
      end

      private def build_display(builder : Builder) : Nil
        builder.puts("#{@object.leave_type.name.colorize.white.bold}  Draft")
        builder.puts

        labelled(builder, "Dates", dates)
        labelled(builder, "Hours", Utils::Duration.compact(@object.hours))

        reason = @object.reason
        labelled(builder, "Reason", reason) if reason

        build_balance(builder)

        case breakdown = @breakdown
        in Models::LeaveBreakdown
          build_breakdown(builder, breakdown)
        in Models::LeaveBreakdown::Mismatch
          build_holidays(builder)
          build_mismatch(builder, breakdown)
        in Nil
          build_holidays(builder)
        end
      end

      private def build_mismatch(builder : Builder, mismatch : Models::LeaveBreakdown::Mismatch) : Nil
        builder.puts
        builder.puts(
          "#{"Warning:".colorize.yellow} Tanda is charging #{Utils::Duration.compact(mismatch.charged)}, " \
          "but your regular hours over these dates come to #{Utils::Duration.compact(mismatch.scheduled)}"
        )
        builder.puts("         No day by day breakdown while those disagree (#{Utils::Duration.compact(mismatch.difference)} apart)")
      end

      private def build_breakdown(builder : Builder, breakdown : Models::LeaveBreakdown) : Nil
        builder.puts

        table = Table.new([
          Table::Column.new("DATE"),
          Table::Column.new("HOURS", align: :right),
          Table::Column.new("NOTE"),
        ])

        breakdown.days.each do |day|
          table << Table::Row.new(
            [
              breakdown_date(breakdown, day),
              day.deducted? ? Utils::Duration.compact(day.hours) : NOTHING,
              day.note || "",
            ],
            gutter: day.holiday? ? HOLIDAY_GUTTER : ' '
          )
        end

        table.summarise(HOURS_COLUMN, Utils::Duration.compact(breakdown.total), pretty_deducted(breakdown))
        table.build(builder, header: false)
      end

      private def breakdown_date(breakdown : Models::LeaveBreakdown, day : Models::LeaveBreakdown::Day) : String
        return Utils::Time.pretty_short_date(day.date) if breakdown.crosses_year?

        Utils::Time.short_date(day.date)
      end

      private def pretty_deducted(breakdown : Models::LeaveBreakdown) : String
        total = breakdown.days.size

        "#{breakdown.deducted_days} of #{total} day#{"s" if total != 1} deducted"
      end

      private def labelled(builder : Builder, label : String, value : String) : Nil
        builder.puts("  #{label.ljust(LABEL_WIDTH)}#{value}")
      end

      private def build_holidays(builder : Builder) : Nil
        return if @holidays.empty?

        builder.puts

        @holidays.each do |holiday|
          builder.puts("#{HOLIDAY_GUTTER} #{Utils::Time.short_date(holiday.start)}  #{holiday_name(holiday)}")
        end
      end

      private def build_balance(builder : Builder) : Nil
        balance = @balance
        return if balance.nil?

        remaining = balance.span - @object.hours

        labelled(
          builder,
          "Balance",
          "#{pretty_balance(balance.span)} → #{pretty_remaining(remaining)} if approved"
        )
      end

      private def pretty_balance(span : Time::Span) : String
        days = whole_days(span)
        return Utils::Duration.compact(span) if days.nil?

        "#{Utils::Duration.compact(span)} (#{days} days)"
      end

      private def pretty_remaining(span : Time::Span) : String
        return "#{Utils::Duration.compact(span.abs)} over" if span.negative?

        pretty_balance(span)
      end

      private def whole_days(span : Time::Span) : Int32?
        length = @day_length
        return if length.nil? || length.zero? || span.zero?
        return unless (span.total_minutes % length.total_minutes).zero?

        (span.total_minutes / length.total_minutes).to_i
      end

      private def holiday_name(holiday : API::Types::LeaveRequest) : String
        reason = holiday.reason
        return HOLIDAY_NOTE if reason.nil? || reason.blank?

        reason.rchop(LeaveList::AUTO_APPLIED)
      end

      private def dates : String
        range = Utils::Time.date_range(@object.start, @object.finish)
        return range if @object.single_day?

        breakdown = @breakdown
        return "#{range}  (#{@object.days} days)" unless breakdown.is_a?(Models::LeaveBreakdown)

        "#{range}  (#{@object.days} days, #{breakdown.deducted_days} deducted)"
      end
    end
  end
end
