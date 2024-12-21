module TandaCLI
  class Current
    struct User
      getter id : Int32
      getter organisation_name : String
      getter time_zone : Time::Location

      def initialize(@id : Int32, @organisation_name : String, time_zone : String)
        @time_zone = Time::Location.load(time_zone)
      end
    end

    def initialize(@user = User); end

    getter user : User
  end
end
