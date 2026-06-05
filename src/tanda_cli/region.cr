module TandaCLI
  enum Region
    Global
    APAC
    EU
    InternalGlobal
    InternalAPAC

    def production_host : String
      case self
      in .global?          then "my.workforce.com"
      in .apac?            then "my.tanda.co"
      in .eu?              then "eu.tanda.co"
      in .internal_global? then "internal.workforce.com"
      in .internal_apac?   then "internal.tanda.co"
      end
    end

    def staging_host : String
      case self
      in .global? then "staging.workforce.com"
      in .apac?   then "staging.tanda.co"
      in .eu?     then "staging.eu.tanda.co"
      in .internal_global?, .internal_apac?
        raise "Internal regions have no staging environment"
      end
    end

    def display_name : String
      case self
      in .global?          then "Global"
      in .apac?            then "APAC"
      in .eu?              then "EU"
      in .internal_global? then "Global (Internal)"
      in .internal_apac?   then "APAC (Internal)"
      end
    end

    def internal? : Bool
      internal_global? || internal_apac?
    end
  end
end
