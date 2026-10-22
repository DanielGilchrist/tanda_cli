require "./base"
require "./table"
require "../api/types/leave_request"
require "../utils/duration"

module TandaCLI
  module Representers
    struct LeaveList < Base(Array(API::Types::LeaveRequest))
      HOLIDAY_GUTTER = '·'
      AUTO_APPLIED   = " (auto applied)"
      TYPE_SUFFIX    = " Leave"
      TYPE_MAX_WIDTH = 12

      def initialize(object : T, @show_ids : Bool = false, @hidden_holidays : Array(API::Types::LeaveRequest) = T.new) : Nil
        super(object)
      end

      private def build_display(builder : Builder) : Nil
        table = Table.new(columns)
        @object.each { |request| table << row_for(request) }

        build_summary(table)
        table.build(builder)
      end

      private def columns : Array(Table::Column)
        columns = [Table::Column.new("DATE")]

        columns << Table::Column.new("UNTIL") if spans_days?
        columns << Table::Column.new("HOURS", align: :right)
        columns << Table::Column.new("TYPE", max_width: TYPE_MAX_WIDTH)
        columns << Table::Column.new("STATUS") unless shared_status
        columns << Table::Column.new("ID") if @show_ids
        columns << Table::Column.new("REASON")

        columns
      end

      private getter? spans_days : Bool do
        @object.any? { |request| !request.single_day? }
      end

      private def hours_column : Int32
        spans_days? ? 2 : 1
      end

      private getter shared_status : String? do
        return if @object.size < 2

        statuses = @object.map(&.status.to_s).uniq!
        statuses.first if statuses.one?
      end

      private def row_for(request : API::Types::LeaveRequest) : Table::Row
        holiday = request.public_holiday?

        cells = [Utils::Time.pretty_short_date(request.start)]

        cells << until_for(request) if spans_days?
        cells << Utils::Duration.compact(request.hours)
        cells << pretty_type(request.leave_type)

        cells << request.status.to_s unless shared_status
        cells << "##{request.id}" if @show_ids
        cells << pretty_reason(request, holiday)

        Table::Row.new(cells, gutter: holiday ? HOLIDAY_GUTTER : ' ')
      end

      private def until_for(request : API::Types::LeaveRequest) : String
        return "" if request.single_day?

        if request.start.year == request.finish.year
          Utils::Time.short_date(request.finish)
        else
          Utils::Time.pretty_short_date(request.finish)
        end
      end

      private def build_summary(table : Table) : Nil
        holidays = @object.select(&.public_holiday?)
        total = total_hours(@object)

        table.summarise(hours_column, Utils::Duration.compact(total), pretty_total(@object.size))

        yours = @object.reject(&.public_holiday?)

        unless holidays.empty? || yours.empty?
          table.summarise(hours_column, Utils::Duration.compact(total_hours(yours)), "#{yours.size} yours")
          table.summarise(
            hours_column,
            Utils::Duration.compact(total_hours(holidays)),
            "#{pretty_holidays(holidays.size)} (#{HOLIDAY_GUTTER})"
          )
        end

        build_hidden_holidays(table)
      end

      private def build_hidden_holidays(table : Table) : Nil
        return if @hidden_holidays.empty?

        table.summarise(
          hours_column,
          Utils::Duration.compact(total_hours(@hidden_holidays)),
          "#{pretty_holidays(@hidden_holidays.size)} not shown"
        )
      end

      private def total_hours(requests : Array(API::Types::LeaveRequest)) : Time::Span
        requests.sum(Time::Span.zero, &.hours)
      end

      private def pretty_total(count : Int32) : String
        requests = "#{count} request#{"s" if count != 1}"
        status = shared_status

        status ? "#{requests}, all #{status.downcase}" : requests
      end

      private def pretty_holidays(count : Int32) : String
        "#{count} auto-applied public holiday#{"s" if count != 1}"
      end

      private def pretty_type(leave_type : String) : String
        leave_type.rchop(TYPE_SUFFIX)
      end

      private def pretty_reason(request : API::Types::LeaveRequest, holiday : Bool) : String
        reason = request.reason
        return "" if reason.nil? || reason.blank?

        holiday ? reason.rchop(AUTO_APPLIED) : reason
      end
    end
  end
end
