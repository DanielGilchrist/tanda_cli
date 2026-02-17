module TandaCLI
  module Commands
    class Auth
      class Login < Base
        SCOPES = "device leave personal roster timesheet me"

        def setup_
          @name = "login"
          @summary = @description = "Authenticate with Tanda"
        end

        def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
          config.reset_environment!

          display.puts "🔐 #{"Tanda CLI Login".colorize.white.bold}"
          display.puts

          email, password = prompt_for_credentials
          region, access_token = detect_region_and_authenticate(email, password)

          config.overwrite!(region, email, access_token)

          url = config.api_url
          display.error!(url) unless url.is_a?(String)

          client = API::Client.new(url, access_token.token)
          select_and_save_organisation(client)
        end

        private def prompt_for_credentials : Tuple(String, String)
          email = input.request_or(message: "📧 #{"Email:".colorize.cyan}") do
            display.error!("Email cannot be blank")
          end
          display.puts

          password = input.request_or(message: "🔑 #{"Password:".colorize.cyan}", sensitive: true) do
            display.error!("Password cannot be blank")
          end
          display.puts

          {email, password}
        end

        private def detect_region_and_authenticate(email : String, password : String) : Tuple(Region, Types::AccessToken)
          staging = config.staging?

          display.puts "🔍 #{"Authenticating...".colorize.cyan}"

          Region.values.each do |region|
            Log.debug(&.emit("Trying #{region.display_name} (#{region.host(staging)})"))

            access_token = try_authenticate(region, email, password, staging)
            if access_token
              Log.debug(&.emit("Authenticated via #{region.display_name}"))
              display.success("Authenticated!")
              return {region, access_token}
            end
          end

          display.error!("Unable to authenticate (incorrect email or password)")
        end

        private def try_authenticate(region : Region, email : String, password : String, staging : Bool) : Types::AccessToken?
          url = region.oauth_url(:token, staging)

          response = HTTP::Client.post(
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

          Log.debug(&.emit("Response from #{region.display_name}", body: response.body))

          return nil unless response.success?

          Types::AccessToken.from_json(response.body)
        rescue Socket::Addrinfo::Error
          Log.debug(&.emit("Network error for #{region.display_name}"))
          nil
        rescue JSON::SerializableError | JSON::ParseException
          Log.debug(&.emit("Failed to parse response from #{region.display_name}"))
          nil
        end

        private def select_and_save_organisation(client : API::Client)
          me = client.me.unwrap!
          organisations = Configuration::Serialisable::Organisation.from(me)

          display.error!("You don't have access to any organisations") if organisations.empty?

          organisation = organisations.first if organisations.one?
          unless organisation
            display.puts
            display.puts "🏢 #{"Select an organisation:".colorize.white.bold}"
            while organisation.nil?
              organisation = prompt_for_organisation(organisations)
            end
          end

          organisation.current = true
          config.organisations = organisations
          config.save!

          display.puts
          display.success("Selected organisation \"#{organisation.name}\"")
          display.success("Organisations saved to config")
        end

        private def prompt_for_organisation(
          organisations : Array(Configuration::Serialisable::Organisation),
        ) : Configuration::Serialisable::Organisation?
          organisations.each_with_index(1) do |org, index|
            display.puts "  #{index.to_s.colorize.cyan}: #{org.name}"
          end

          input.request_and(message: "\n#{"Enter a number:".colorize.cyan}") do |user_input|
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
