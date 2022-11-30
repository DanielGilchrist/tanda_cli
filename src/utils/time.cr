module Tanda::CLI
  module Utils
    module Time
      extend self

      DEFAULT_DATE_FORMAT = "%A, %d %b %Y"

      def now : ::Time
        ::Time.local(location: Current.user.time_zone)
      end

      def pretty_date(date : ::Time) : String
        ::Time::Format.new(DEFAULT_DATE_FORMAT).format(date)
      end
    end
  end
end
