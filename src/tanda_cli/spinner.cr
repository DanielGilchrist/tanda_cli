require "colorize"

module TandaCLI
  module Spinner
    extend self

    FRAMES   = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏]
    INTERVAL = 80.milliseconds

    QUIET_PERIOD = 250.milliseconds

    CLEAR_LINE = "\r\e[K"

    class_property? enabled : Bool = false

    @@depth = 0
    @@stop = Channel(Nil).new
    @@stopped = Channel(Nil).new

    def while_working(message : String, io : IO = STDERR, & : -> T) : T forall T
      return yield unless enabled?

      start(message, io)

      begin
        yield
      ensure
        stop
      end
    end

    private def start(message : String, io : IO) : Nil
      @@depth += 1
      return unless @@depth == 1

      spawn do
        spin(message, io) if wait(QUIET_PERIOD)

        @@stopped.send(nil)
      end
    end

    private def stop : Nil
      @@depth -= 1
      return unless @@depth.zero?

      @@stop.send(nil)
      @@stopped.receive
    end

    private def spin(message : String, io : IO) : Nil
      index = 0

      loop do
        io.print("#{CLEAR_LINE}#{FRAMES[index]} #{message.colorize.dark_gray}")
        io.flush
        index = (index + 1) % FRAMES.size

        break unless wait(INTERVAL)
      end

      io.print(CLEAR_LINE)
      io.flush
    end

    private def wait(duration : Time::Span) : Bool
      select
      when @@stop.receive
        false
      when timeout(duration)
        true
      end
    end
  end
end
