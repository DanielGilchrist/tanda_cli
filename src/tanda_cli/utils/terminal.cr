{% if flag?(:unix) %}
  @[Link("c")]
  lib LibTerminal
    struct Winsize
      ws_row : UInt16
      ws_col : UInt16
      ws_xpixel : UInt16
      ws_ypixel : UInt16
    end

    fun ioctl(fd : Int32, request : LibC::ULong, ...) : Int32
  end
{% end %}

module TandaCLI
  module Utils
    module Terminal
      extend self

      {% if flag?(:darwin) %}
        TIOCGWINSZ = 0x40087468_u64
      {% elsif flag?(:linux) %}
        TIOCGWINSZ = 0x5413_u64
      {% end %}

      def width? : Int32?
        from_env? || from_ioctl?
      end

      private def from_env? : Int32?
        columns = ENV["COLUMNS"]?.try(&.to_i?)
        columns if columns && columns.positive?
      end

      private def from_ioctl? : Int32?
        {% if flag?(:unix) && (flag?(:darwin) || flag?(:linux)) %}
          return unless STDOUT.tty?

          winsize = LibTerminal::Winsize.new
          return unless LibTerminal.ioctl(1, TIOCGWINSZ, pointerof(winsize)).zero?

          columns = winsize.ws_col.to_i
          columns if columns.positive?
        {% end %}
      end
    end
  end
end
