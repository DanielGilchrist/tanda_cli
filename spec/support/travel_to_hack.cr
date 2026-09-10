module TandaCLI
  module Utils
    module Time
      @@mutex = Mutex.new
      @@now : ::Time? = nil

      def travel_to(time : ::Time, & : ->) : Nil
        @@mutex.synchronize do
          @@now = time
          yield
        ensure
          @@now = nil
        end
      end

      def now : ::Time
        @@now || ::Time.local
      end
    end
  end
end

def travel_to(time : Time, &block : ->) : Nil
  TandaCLI::Utils::Time.travel_to(time, &block)
end
