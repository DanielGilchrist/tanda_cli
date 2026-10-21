module TandaCLI
  module Models
    module LeaveLookup
      struct Id
        def initialize(@value : Int32) : Nil; end

        getter value : Int32
      end
    end
  end
end
