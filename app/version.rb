class Version
  class << self
    # Parse `CHANGELOG.md` to find the current version number
    # We assume versions are latest-first and all following the markdown format:
    #
    #     ## v1.2.3
    #
    #     some notes
    #
    #     ## v1.2.2
    #
    #     some other notes
    #
    #     ## v1.1.1
    #
    #     more notes
    def find!
      changelog = APP_ROOT.join('CHANGELOG.md')

      File
        .read(changelog)
        .split("\n")
        .each do |line|
          m = line.match(/## (v\d+\.\d+\.\d+)/)
          return m[1] if m
        end
    end
  end
end
