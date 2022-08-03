module Tanda::CLI
  module Current
    extend self

    class User
      getter id : Int32
      getter time_zone : Time::Location

      def initialize(@id : Int32, time_zone : String)
        @time_zone = Time::Location.load(time_zone)
      end
    end

    delegate user!, :user=, to: instance

    private def instance
      @@_current ||= CurrentInstance.new
    end

    private class CurrentInstance
      getter user : User?

      def initialize
        @user = nil
      end

      def user=(user : User)
        @user = user
      end

      def user! : User
        nilable_user = user
        raise UserNotSet.new unless nilable_user

        nilable_user
      end

      private class UserNotSet < Exception
        def initialize
          @message = "User hasn't been set!"
        end
      end
    end
  end
end
