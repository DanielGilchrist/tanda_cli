module Tanda::CLI
  module CLI::Auth
    extend self

    VALID_SITE_PREFIXES = Set{"my", "eu", "us"}

    def request_user_information! : Tuple(String, String, String)
      valid_site_prefixes = VALID_SITE_PREFIXES.join(", ")
      site_prefix = try_request_input!(message: "Site prefix (#{valid_site_prefixes}):", error_prefix: "Site prefix")

      unless VALID_SITE_PREFIXES.includes?(site_prefix)
        Utils::Display.error!("Invalid site prefix") do |sub_errors|
          sub_errors << "Site prefix must be one of #{valid_site_prefixes}"
        end
      end

      email = try_request_input!(message: "Whats your email?", error_prefix: "Email")

      password = STDIN.noecho do
        try_request_input!(message: "What's your password?", error_prefix: "Password")
      end

      {site_prefix, email, password}
    end

    private def try_request_input!(message : String, error_prefix : String) : String
      puts "#{message}\n"
      input = gets.try(&.chomp).presence || Utils::Display.error!("#{error_prefix} cannot be blank")
      puts ""

      input
    end
  end
end
