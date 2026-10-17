module TandaCLI
  class Current
    struct User
      def initialize(@id : Int32, @organisation_name : String) : Nil; end

      getter id : Int32
      getter organisation_name : String
    end
  end
end
