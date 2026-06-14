require "kebab"

module TandaCLI
  module Commands
    @[Kebab::Command(name: "me", summary: "Get your own information")]
    struct Me
      include Kebab::Parseable

      def run(context : Context) : Nil
        display = context.display
        me = context.client.users.me.or { |error| display.error!(error) }
        Representers::Me.new(me).display(display)
      end
    end
  end
end
