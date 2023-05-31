require "admiral"
require "../client_builder"

module Tanda::CLI
  class CLI::Commmands
    class Me < Admiral::Command
      include CLI::ClientBuilder

      def run
        me = client.me.or(&.display!)
        Representers::Me.new(me).display
      end
    end
  end
end
