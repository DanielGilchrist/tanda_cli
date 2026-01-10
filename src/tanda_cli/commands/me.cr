module TandaCLI
  module Commands
    class Me < Base
      def setup_
        @name = "me"
        @summary = @description = "Get your own information"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        me = client.me.get.or { |error| display.error!(error) }
        Representers::Me.new(me).display(display)
      end
    end
  end
end
