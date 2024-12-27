module TandaCLI
  module Utils
    module Time
      @@now : ::Time? = nil

      def travel_to(time : ::Time)
        now = @@now
        raise("travel_to has already been called with '#{now}'") if now

        @@now = time
      end

      def reset!
        @@now = nil
      end

      def now : ::Time
        @@now || ::Time.local
      end
    end
  end
end

def travel_to(time : Time)
  TandaCLI::Utils::Time.travel_to(time)
end
