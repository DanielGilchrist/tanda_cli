module Tanda::CLI
  class CLI::Auth
    def self.request_user_information! : Tuple(String, String, String)
      site_prefix = begin
        puts "Site prefix:\n"
        res = gets
        res ? res.chomp : exit
      end
      puts ""

      email = begin
        puts "Whats your email?\n"
        res = gets
        res ? res.chomp : exit
      end
      puts ""

      password = begin
        puts "What's your password?\n"
        res = gets
        res ? res.chomp : exit
      end
      puts ""

      {site_prefix, email, password}
    end
  end
end
