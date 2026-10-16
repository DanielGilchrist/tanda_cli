require "./error/editor_failed"

module TandaCLI
  struct Editor
    def self.from_environment : Editor?
      command = ENV["VISUAL"]?.presence || ENV["EDITOR"]?.presence
      new(command) if command
    end

    def initialize(@command : String) : Nil; end

    getter command : String

    def edit(text : String) : String | Error::EditorFailed
      file = File.tempfile("regular_hours", ".txt") { |io| io << text }

      status = Process.run(
        "#{@command} #{Process.quote(file.path)}",
        shell: true,
        input: Process::Redirect::Inherit,
        output: Process::Redirect::Inherit,
        error: Process::Redirect::Inherit,
      )
      return Error::EditorFailed.new(@command, status) unless status.success?

      File.read(file.path)
    ensure
      file.try(&.delete)
    end
  end
end
