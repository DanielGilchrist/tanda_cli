require "../table"
require "../../utils/duration"

module TandaCLI
  module Representers
    module Leave
      module Shared
        HOLIDAY_GUTTER = '·'
        HOLIDAY_NOTE   = "public holiday"
        AUTO_APPLIED   = " (auto applied)"
        NOTHING        = "– "
        HOURS_COLUMN   = 1
        LABEL_WIDTH    = 9

        def self.holiday_name(leave_request : API::Types::LeaveRequest) : String
          reason = leave_request.reason
          return HOLIDAY_NOTE if reason.nil? || reason.blank?

          reason.rchop(AUTO_APPLIED)
        end

        private def labelled(builder : Builder, label : String, value : String) : Nil
          builder.puts("  #{label.ljust(LABEL_WIDTH)}#{value}")
        end

        private def breakdown_table : Table
          Table.new([
            Table::Column.new("DATE"),
            Table::Column.new("HOURS", align: :right),
            Table::Column.new("NOTE"),
          ])
        end

        private def pretty_deducted(deducted : Int32, total : Int32) : String
          "#{deducted} of #{total} day#{"s" if total != 1} deducted"
        end
      end
    end
  end
end
