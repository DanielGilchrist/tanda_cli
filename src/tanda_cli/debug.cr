require "colorize"
require "log"

module TandaCLI
  module Debug
    def self.setup
      Log.setup(:debug, Backend.new)
    end

    class Backend < Log::IOBackend
      def write(entry : Log::Entry)
        Utils::Display.print "\n"
        pp "================================= DEBUG ================================="
        Utils::Display.print entry.message.colorize.yellow
        Utils::Display.print "\n"
        entry.data.each do |(k, v)|
          next if v.raw.nil?

          key = "#{k}: "
          print "#{key.colorize.light_yellow}"
          pp v
          Utils::Display.print "\n" unless http_debug_message?(entry)
        end
        pp "================================= DEBUG ================================="
        Utils::Display.print "\n"
      end

      private def http_debug_message?(entry : Log::Entry)
        entry.message == "Performing request"
      end
    end
  end
end
