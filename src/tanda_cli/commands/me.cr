module TandaCLI
  module Commands
    class Me < Base
      def setup_
        @name = "me"
        @summary = @description = "Get your own information"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        me = client.me.or(&.display!)
        Representers::Me.new(me).display(io)
      end
    end
  end
end
