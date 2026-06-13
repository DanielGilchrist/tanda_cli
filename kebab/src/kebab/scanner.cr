require "./token"

module Kebab
  module Scanner
    extend self

    def scan(arg : String) : Token
      return Tokens::Positional.new(arg) if arg == "-" || arg.empty?
      return Tokens::Separator.new if arg == "--"

      if arg.starts_with?("--")
        name, _, value = arg.lchop("--").partition('=')
        Tokens::Long.new(name, arg.includes?('=') ? value : nil)
      elsif arg.starts_with?('-')
        chars, _, value = arg.lchop('-').partition('=')
        Tokens::Shorts.new(chars, arg.includes?('=') ? value : nil)
      else
        Tokens::Positional.new(arg)
      end
    end
  end
end
