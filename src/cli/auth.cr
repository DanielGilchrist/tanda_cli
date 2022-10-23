module Tanda::CLI
  module CLI::Auth
    extend self

    VALID_SITE_PREFIXES = Set{"my", "eu", "us"}

    def request_user_information! : Tuple(String, String, String)
      valid_site_prefixes = VALID_SITE_PREFIXES.join(", ")
      site_prefix = try_get_input!(message: "Site prefix (#{valid_site_prefixes}):", error_prefix: "Site prefix")

      unless VALID_SITE_PREFIXES.includes?(site_prefix)
        Utils::Display.error("Invalid site prefix")
        Utils::Display.sub_error("Site prefix must be one of #{valid_site_prefixes}")
        exit
      end

      email = try_get_input!(message: "Whats your email?", error_prefix: "Email")

      password = STDIN.noecho do
        try_get_input!(message: "What's your password?", error_prefix: "Password")
      end

      {site_prefix, email, password}
    end

    private def try_get_input!(message : String, error_prefix : String) : String
      puts "#{message}\n"
      input = gets.try(&.chomp).presence || handle_invalid_input!("#{error_prefix} cannot be blank")
      puts ""

      input
    end

    private def handle_invalid_input!(message : String) : NoReturn
      Utils::Display.error(message)
      exit
    end
  end
end
