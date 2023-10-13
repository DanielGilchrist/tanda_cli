# internal
require "./tanda_cli/**"

module TandaCLI
  extend self

  def main(args = ARGV)
    Commands::Main.new.execute(args)
  end
end

{% if flag?(:debug) %}
  require "./debug"
  TandaCLI::Debug.setup
{% end %}

# Tests should call this explicitly
{% unless flag?(:test) %}
  TandaCLI.main
{% end %}
