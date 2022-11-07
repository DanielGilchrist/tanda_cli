require "colorize"
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
        pp entry.message.colorize(:red)
        entry.data.each do |(k, v)|
          print "#{"#{k}:".colorize(:yellow)} "
          pp v
          puts "\n"
        end
        pp "=============================== DEBUG ==============================="
        puts "\n"
      end
    end
  end
end
