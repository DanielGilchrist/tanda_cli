require "log"

module Tanda::CLI
  module Debug
    def self.setup
      return unless ENV["DEBUG"]? == "true"

      Log.setup(:debug, Backend.new)
    end

    class Backend < Log::IOBackend
      def write(entry : Log::Entry)
        puts "\n"
        puts "=============================== DEBUG ==============================="
        puts entry.message
        puts entry.data
        puts "=============================== DEBUG ==============================="
        puts "\n"
      end
    end
  end
end
