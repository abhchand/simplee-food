require 'tempfile'

module FixtureHelpers
  # Creates a `Tempfile` from one of the test fixture files
  #
  # @see https://rubyapi.org/o/Tempfile
  # @param fixture_name [String] the filename of one of the fixtures in the
  #   spec/fixtures/* folder
  # @return [Tempfile]
  def create_tempfile_from_fixture(fixture_name)
    key = File.basename(fixture_name, '.*')
    content = File.read(ROOT.join('spec', 'fixtures', fixture_name))

    Tempfile
      .new(key)
      .tap do |temp|
        temp.write(content)
        temp.rewind
      end
  end
end
