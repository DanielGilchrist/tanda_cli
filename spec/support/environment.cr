def set_environment(name : String, value : String?) : Nil
  if value
    ENV[name] = value
  else
    ENV.delete(name)
  end
end

def with_environment(variables : Hash(String, String?), & : -> Nil) : Nil
  original = variables.keys.to_h { |name| {name, ENV[name]?} }

  variables.each { |name, value| set_environment(name, value) }

  yield
ensure
  original.try(&.each { |name, value| set_environment(name, value) })
end
