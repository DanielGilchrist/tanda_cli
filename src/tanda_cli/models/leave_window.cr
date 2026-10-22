require "../error/backwards_leave_window"
require "../error/leave_window_too_long"

module TandaCLI
  module Models
    # A date range the leave API will accept, which caps how many days can be looked up at once
    struct LeaveWindow
      MAX_DAYS = 366

      def self.upcoming : LeaveWindow
        today = Utils::Time.now.at_beginning_of_day
        new(today, today.shift(years: 1, days: -1))
      end

      def self.taken : LeaveWindow
        today = Utils::Time.now.at_beginning_of_day
        new(today.shift(years: -1, days: 1), today)
      end

      def self.this_year : LeaveWindow
        today = Utils::Time.now.at_beginning_of_day
        new(today.at_beginning_of_year, today.at_end_of_year.at_beginning_of_day)
      end

      def self.on(date : Time) : LeaveWindow
        day = date.at_beginning_of_day
        new(day, day)
      end

      def self.between(from : Time?, to : Time?) : LeaveWindow | Error::Base
        if from.nil?
          return this_year if to.nil?

          return bounded(to.shift(years: -1, days: 1), to)
        end

        return bounded(from, from.shift(years: 1, days: -1)) if to.nil?

        bounded(from, to)
      end

      private def self.bounded(from : Time, to : Time) : LeaveWindow | Error::Base
        start = from.at_beginning_of_day
        finish = to.at_beginning_of_day

        if finish < start
          return Error::BackwardsLeaveWindow.new(start, finish)
        end

        days = (finish - start).total_days.round.to_i + 1
        return Error::LeaveWindowTooLong.new(days, MAX_DAYS) if days > MAX_DAYS

        new(start, finish)
      end

      private def initialize(@from : Time, @to : Time) : Nil; end

      getter from : Time
      getter to : Time

      def covers?(date : Time) : Bool
        day = date.at_beginning_of_day

        day >= from && day <= to
      end

      def to_s(io : IO) : Nil
        io << Utils::Time.pretty_date(from) << " to " << Utils::Time.pretty_date(to)
      end
    end
  end
end
