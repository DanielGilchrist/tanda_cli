module TandaCLI
  class Current
    struct User
      getter id : Int32
      getter organisation_name : String

      def initialize(@id : Int32, @organisation_name : String); end
    end

    def initialize(@user = User); end

    getter user : User
  end
end
