RSpec.configure do |config|
  config.before(:suite) do
    # Determine if we even need to run rollup based on what spec types we're
    # running.
    should_run_rollup =
      RSpec.world.registered_example_group_files.any? do |f|
        f =~ %r{spec/(features)}
      end
    next unless should_run_rollup

    # Right now we just blindly run the whole frontend build, because the
    # frontend build doesn't take long (a few seconds).
    #
    # In the future if the build starts taking longer we should further
    # optimize this to look at the manifest and only run the build if a frontend
    # asset has been modified since the last build.
    puts '🕸️ Running frontend build (rollup.js)...'
    Dir.chdir(ROOT) { system 'yarn run build:test' }
  end
end
