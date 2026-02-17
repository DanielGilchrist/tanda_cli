module TandaCLI
  module Commands
    class Auth
      class Login < Base
        VALID_SITE_PREFIXES = {"my", "eu", "us"}
        SCOPES              = "device leave personal roster timesheet me"

        def setup_
          @name = "login"
          @summary = @description = "Authenticate with Tanda"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config.reset_environment!

          site_prefix, email, password = prompt_for_credentials
          config.site_prefix = site_prefix

          access_token = fetch_access_token(email, password)

          config.overwrite!(site_prefix, email, access_token)
          display.success("Retrieved token!#{config.staging? ? " (staging)" : ""}\n")

          url = config.api_url
          display.error!(url) unless url.is_a?(String)

          client = API::Client.new(url, access_token.token)
          select_and_save_organisation(client)
        end

        private def prompt_for_credentials : Tuple(String, String, String)
          valid_site_prefixes = VALID_SITE_PREFIXES.join(", ")
          site_prefix = input.request_or(message: "Site prefix (#{valid_site_prefixes} - Default is \"my\"):") do
            "my".tap { |default| display.warning("Defaulting to \"#{default}\"") }
          end

          unless VALID_SITE_PREFIXES.includes?(site_prefix)
            display.error!("Invalid site prefix") do |sub_errors|
              sub_errors << "Site prefix must be one of #{valid_site_prefixes}"
            end
          end
          display.puts

          email = input.request_or(message: "What's your email?") do
            display.error!("Email cannot be blank")
          end
          display.puts

          password = input.request_or(message: "What's your password?", sensitive: true) do
            display.error!("Password cannot be blank")
          end
          display.puts

          {site_prefix, email, password}
        end

        private def fetch_access_token(email : String, password : String) : Types::AccessToken
          url = config.oauth_url(:token)
          display.error!(url) unless url.is_a?(String)

          response = begin
            HTTP::Client.post(
              url,
              headers: HTTP::Headers{
                "Cache-Control" => "no-cache",
                "Content-Type"  => "application/json",
              },
              body: {
                username:   email,
                password:   password,
                scope:      SCOPES,
                grant_type: "password",
              }.to_json
            )
          rescue Socket::Addrinfo::Error
            display.fatal!("There appears to be a problem with your internet connection")
          end

          Log.debug(&.emit("Response", body: response.body))

          API::Result(Types::AccessToken).from(response).or do |error|
            display.error!("Unable to authenticate (likely incorrect login details)") do |sub_errors|
              sub_errors << "Error Type: #{error.error}\n"

              description = error.error_description
              sub_errors << "Message: #{description}" if description
            end
          end
        end

        private def select_and_save_organisation(client : API::Client)
          me = client.me.unwrap!
          organisations = Configuration::Serialisable::Organisation.from(me)

          display.error!("You don't have access to any organisations") if organisations.empty?

          organisation = organisations.first if organisations.one?
          while organisation.nil?
            organisation = prompt_for_organisation(organisations)
          end

          organisation.current = true
          config.organisations = organisations
          config.save!

          display.success("Selected organisation \"#{organisation.name}\"")
          display.success("Organisations saved to config")
        end

        private def prompt_for_organisation(
          organisations : Array(Configuration::Serialisable::Organisation),
        ) : Configuration::Serialisable::Organisation?
          display.puts "Which organisation would you like to use?"
          organisations.each_with_index(1) do |org, index|
            display.puts "#{index}: #{org.name}"
          end

          input.request_and(message: "\nEnter a number:") do |user_input|
            number = user_input.try(&.to_i32?)

            if number
              index = number - 1
              organisations[index]? || handle_invalid_selection(organisations.size, user_input)
            else
              handle_invalid_selection
            end
          end
        end

        private def handle_invalid_selection(length : Int32? = nil, user_input : String? = nil) : Nil
          display.puts "\n"
          if user_input
            display.error("Invalid selection", user_input) do |sub_errors|
              sub_errors << "Please select a number between 1 and #{length}" if length
            end
          else
            display.error("You must enter a number")
          end
        end
      end
    end
  end
end
