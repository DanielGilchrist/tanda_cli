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
      HOURS_COLUMN   =  1

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
        columns = [
          Table::Column.new("DATE"),
          Table::Column.new("HOURS", align: :right),
          Table::Column.new("TYPE", max_width: TYPE_MAX_WIDTH),
        ]

        columns << Table::Column.new("STATUS") unless shared_status
        columns << Table::Column.new("ID") if @show_ids
        columns << Table::Column.new("REASON")

        columns
      end

      private getter shared_status : String? do
        return if @object.size < 2

        statuses = @object.map(&.status.to_s).uniq!
        statuses.first if statuses.one?
      end

      private def row_for(request : API::Types::LeaveRequest) : Table::Row
        holiday = request.public_holiday?

        cells = [
          Utils::Time.date_range(request.start, request.finish),
          Utils::Duration.compact(request.hours),
          pretty_type(request.leave_type),
        ]

        cells << request.status.to_s unless shared_status
        cells << "##{request.id}" if @show_ids
        cells << pretty_reason(request, holiday)

        Table::Row.new(cells, gutter: holiday ? HOLIDAY_GUTTER : ' ')
      end

      private def build_summary(table : Table) : Nil
        holidays = @object.select(&.public_holiday?)
        total = total_hours(@object)

        table.summarise(HOURS_COLUMN, Utils::Duration.compact(total), pretty_total(@object.size))

        yours = @object.reject(&.public_holiday?)

        unless holidays.empty? || yours.empty?
          table.summarise(HOURS_COLUMN, Utils::Duration.compact(total_hours(yours)), "#{yours.size} yours")
          table.summarise(
            HOURS_COLUMN,
            Utils::Duration.compact(total_hours(holidays)),
            "#{pretty_holidays(holidays.size)} (#{HOLIDAY_GUTTER})"
          )
        end

        build_hidden_holidays(table)
      end

      private def build_hidden_holidays(table : Table) : Nil
        return if @hidden_holidays.empty?

        table.summarise(
          HOURS_COLUMN,
          Utils::Duration.compact(total_hours(@hidden_holidays)),
          "#{pretty_holidays(@hidden_holidays.size)} hidden"
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
