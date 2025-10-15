# TODO: Remove this once shard is fixed. Also just consider replacing what we need
# with own implementation.
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
  end
end
