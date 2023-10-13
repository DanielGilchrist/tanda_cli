module TandaCLI
  module Auth
    extend self

    VALID_SITE_PREFIXES = {"my", "eu", "us"}

    def request_user_information! : Tuple(String, String, String)
      valid_site_prefixes = VALID_SITE_PREFIXES.join(", ")
      site_prefix = request_site_prefix(message: "Site prefix (#{valid_site_prefixes} - Default is \"my\"):")

      unless VALID_SITE_PREFIXES.includes?(site_prefix)
        Utils::Display.error!("Invalid site prefix") do |sub_errors|
          sub_errors << "Site prefix must be one of #{valid_site_prefixes}"
        end
      end
      puts

      email = try_request_input_with_error!(message: "Whats your email?", error_prefix: "Email")
      puts

      password = STDIN.noecho do
        try_request_input_with_error!(message: "What's your password?", error_prefix: "Password")
      end
      puts

      {site_prefix, email, password}
    end

    private def try_request_input_with_error!(message : String, error_prefix : String) : String
      try_request_input(message: message) || Utils::Display.error!("#{error_prefix} cannot be blank")
    end

    private def request_site_prefix(message : String) : String
      input = try_request_input(message: message)
      (input || "my").tap do
        Utils::Display.warning("Defaulting to \"my\"") if input.nil?
      end
    end

    private def try_request_input(message : String) : String?
      puts "#{message}"
      gets.try(&.chomp).presence
    end
  end
end
