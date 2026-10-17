module TandaCLI
  module Commands
    struct Config
      module Target
        macro included
          @[Kebab::Option(short: 's', description: "Act on the state file instead")]
          getter? state : Bool = false
        end

        def file(context : Context) : Storage::AbstractFile
          files = context.files

          return files.state if state?

          files.configuration(context.state.current_environment)
        end
      end
    end
  end
end
