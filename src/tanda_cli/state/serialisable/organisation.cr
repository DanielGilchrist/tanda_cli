module TandaCLI
  class State
    class Serialisable
      class Organisation
        include JSON::Serializable

        def self.from(organisation : API::Types::Me::Organisation) : self
          new(
            organisation.id,
            organisation.name,
            organisation.user_id
          )
        end

        def self.from(me : API::Types::Me) : Array(self)
          me.organisations.map(&->from(API::Types::Me::Organisation))
        end

        def initialize(
          @id : Int32,
          @name : String,
          @user_id : Int32,
          @current : Bool = false,
        ) : Nil; end

        getter id : Int32
        getter name : String
        getter user_id : Int32
        property? current : Bool
      end
    end
  end
end
