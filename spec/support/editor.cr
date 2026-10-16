EDITOR_SCRIPTS = "#{__DIR__}/editors"

def with_editor(script : String, content : String = "", & : -> Nil) : Nil
  capture = File.tempname("regular_hours_capture")
  ENV["EDITOR"] = "#{EDITOR_SCRIPTS}/#{script}.sh"
  ENV["TANDA_CLI_SPEC_EDITOR_CONTENT"] = content
  ENV["TANDA_CLI_SPEC_EDITOR_CAPTURE"] = capture

  yield
ensure
  ENV.delete("EDITOR")
  ENV.delete("TANDA_CLI_SPEC_EDITOR_CONTENT")
  ENV.delete("TANDA_CLI_SPEC_EDITOR_CAPTURE")
end

def editor_received : String
  File.read(ENV["TANDA_CLI_SPEC_EDITOR_CAPTURE"])
end
