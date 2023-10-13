module TandaCLI
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
      getter organisation_name : String
      getter time_zone : Time::Location

      def initialize(@id : Int32, @organisation_name : String, time_zone : String)
        @time_zone = Time::Location.load(time_zone)
      end
    end

    delegate config, user, user?, time_zone, to: instance

    def set_user!(user : User)
      Utils::Display.fatal!(UserAlreadySet.new) if @@user_set

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
      @config : Configuration? = nil
      @maybe_user : User? = nil
      @default_time_zone : Time::Location? = nil

      def config : Configuration
        @config ||= Configuration.init
      end

      def time_zone : Time::Location
        ((user = user?) && user.time_zone) || (@default_time_zone ||= Time::Location.load_local)
      end

      def user=(user : User)
        @maybe_user = user
      end

      def user : User
        nilable_user = @maybe_user
        Utils::Display.fatal!(UserNotSet.new) if nilable_user.nil?

        nilable_user
      end

      def user? : User?
        @maybe_user
      end

      {% if flag?(:test) %}
        def reset!
          @config = nil
          @maybe_user = nil
        end
      {% end %}
    end
  end
end
