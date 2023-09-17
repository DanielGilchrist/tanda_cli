require "cling"
require "../client_builder"

module Tanda::CLI
  module CLI::Commands
    class Me < Cling::Command
      include CLI::ClientBuilder

      def setup : Nil
        @name = "me"
        @description = "Get your own information"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        me = client.me.or(&.display!)
        Representers::Me.new(me).display
      end
    end
  end
end
