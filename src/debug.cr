require "log"

module Tanda::CLI
  module Debug
    def self.setup
      Log.setup(:debug, Backend.new)
    end

    class Backend < Log::IOBackend
      def write(entry : Log::Entry)
        puts "\n"
        pp "=============================== DEBUG ==============================="
        pp entry.message
        entry.data.each do |(k, v)|
          print "#{k}: "
          pp v
        end
        pp "=============================== DEBUG ==============================="
        puts "\n"
      end
    end
  end
end
