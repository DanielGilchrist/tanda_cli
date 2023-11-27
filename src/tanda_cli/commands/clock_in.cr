module TandaCLI
  module Commands
    class ClockIn < Base
      struct Options
        def initialize(@skip_validations : Bool = false, @clockin_photo : String? = nil); end

        getter clockin_photo : String?
        getter? skip_validations
      end

      enum ClockType
        Start
        Finish
        BreakStart
        BreakFinish

        def to_underscore : String
          to_s.underscore
        end
      end

      def self.add_options(command : Cling::Command)
        command.add_option('p', "photo", type: :single, description: "Specify a clockin photo (file path or specify photo name if directory has been set)")
        command.add_option('s', "skip-validations", description: "Skip clock in validations")
      end

      def self.parse_options(options : Cling::Options) : ClockIn::Options
        Options.new(
          skip_validations: options.has?("skip-validations"),
          clockin_photo: options.get?("photo").try(&.as_s)
        )
      end

      def setup_
        @name = "clockin"
        @summary = @description = "Clock in/out"

        add_commands(
          ClockIn::Start.new,
          ClockIn::Finish.new,
          ClockIn::Break.new,
          ClockIn::Photo.new,
          ClockIn::Status.new,
          ClockIn::Display.new
        )
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        Utils::Display.print help_template
      end
    end
  end
end
