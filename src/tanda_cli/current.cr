require "./current/*"

module TandaCLI
  class Current
    def initialize(@user : User) : Nil; end

    getter user : User
  end
end
