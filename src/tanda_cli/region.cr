module TandaCLI
  enum Region
    Global
    APAC
    EU

    def production_host : String
      case self
      in .global? then "my.workforce.com"
      in .apac?   then "my.tanda.co"
      in .eu?     then "eu.tanda.co"
      end
    end

    def staging_host : String
      case self
      in .global? then "staging.workforce.com"
      in .apac?   then "staging.tanda.co"
      in .eu?     then "staging.eu.tanda.co"
      end
    end

    def display_name : String
      case self
      in .global? then "Global"
      in .apac?   then "APAC"
      in .eu?     then "EU"
      end
    end

    def host(staging : Bool = false) : String
      staging ? staging_host : production_host
    end

    def oauth_url(endpoint : Configuration::OAuthEndpoint, staging : Bool = false) : String
      "https://#{host(staging)}/api/oauth/#{endpoint.to_s.downcase}"
    end
  end
end
