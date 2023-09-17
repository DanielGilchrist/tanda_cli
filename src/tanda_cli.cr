# shards
require "option_parser"

# internal
require "./configuration"
require "./current"
require "./utils/**"
require "./api/**"
require "./cli/**"

module Tanda::CLI
  extend self

  def main(args = ARGV)
    CLI::Commands::Main.new.execute(args)
  end
end

{% if flag?(:debug) %}
  require "./debug"
  Tanda::CLI::Debug.setup
{% end %}

# Tests should call this explicitly
{% unless flag?(:test) %}
  Tanda::CLI.main
{% end %}
