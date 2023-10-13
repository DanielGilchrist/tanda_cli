# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args = ARGV)
    {% if flag?(:debug) %}
      TandaCLI::Debug.setup
    {% end %}

    Commands::Main.new.execute(args)
  end
end

# Tests should call this explicitly
{% unless flag?(:test) %}
  TandaCLI.main
{% end %}
