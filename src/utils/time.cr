module Tanda::CLI
  module Utils
    module Time
      extend self

      def now : ::Time
        ::Time.local(location: Current.user.time_zone)
      end
    end
  end
end
