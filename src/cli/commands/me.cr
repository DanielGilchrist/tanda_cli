require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class Me < Base
      include CLI::ClientBuilder

      def setup_
        @name = "me"
        @summary = @description = "Get your own information"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        me = client.me.or(&.display!)
        Representers::Me.new(me).display
      end
    end
  end
end
