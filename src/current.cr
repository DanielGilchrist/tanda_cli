module Tanda::CLI
  module Current
    extend self

    class UserNotSet < Exception
      def initialize
        @message = "User hasn't been set!"
      end
    end

    class UserAlreadySet < Exception
      def initialize
        @message = "User has already been set!"
      end
    end

    class User
      getter id : Int32
      getter time_zone : Time::Location

      def initialize(@id : Int32, time_zone : String)
        @time_zone = Time::Location.load(time_zone)
      end
    end

    delegate user!, to: instance

    def set_user!(user : User)
      raise UserAlreadySet.new if @@user_set

      instance.user = user
      @@user_set = true
    end

    {% if flag?(:test) %}
      def reset!
        instance.reset!
        @@user_set = false
      end
    {% end %}

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

      def reset!
        @user = nil
      end
    end
  end
end
