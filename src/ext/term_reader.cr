# TODO: Remove this once shard is fixed.
# Also just consider replacing what we need with own implementation.
module Term
  class Reader
    def unbuffered(& : ->)
      buffering = begin
        @output.as(IO::FileDescriptor).sync?
      rescue
        false
      end

      begin
        @output.as(IO::FileDescriptor).sync = true
      rescue
      end
      yield
    ensure
      begin
        @output.as(IO::FileDescriptor).sync = buffering || false
      rescue
      end
    end

    # Fixes issues in raw/cooked mode on Linux where prompt wasn't interactive.
    class Mode
      def raw(is_on : Bool = true, & : ->)
        if !is_on || !@input.tty?
          yield
        else
          @input.raw { yield }
        end
      end

      def cooked(is_on : Bool = true, & : ->)
        if !is_on || !@input.tty?
          yield
        else
          @input.cooked { yield }
        end
      end
    end
  end
end
