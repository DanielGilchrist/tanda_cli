module TandaCLI
  module Commands
    class Me < Base
      requires_auth!

      def setup_
        @name = "me"
        @summary = @description = "Get your own information"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        me = client.me.or { |error| display.error!(error) }
        Representers::Me.new(me).display(display)
      end
    end
  end
end
