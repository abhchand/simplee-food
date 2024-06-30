require 'securerandom'
require_relative 'models/config'

# Sinatra takes a `:session_secret` config, which is a secret that it uses to
# verify all of its sessions. This is typically set via an ENV var, but that
# requires the developer to track a separate secret and set another ENV in the
# environment of this application.
#
# Instead, we manage this programmatically. We generate the secret on first
# startup (using `SecureRandom`) and store it in the database. We then read that
# value from the database going forward.
#
# This approach -
#
#     * Eliminates the need to maintain and set an external configuration
#     * Keeps configuration self-contained inside the DB (SQLite file)
#     * Ensures the value is consistent going forward
#     * Still allows the developer to override the generated value with an
#       ENV var if concerned about the security of storing this in the DB
#
# The secret is stored in a DB table called `configs`, which is a table used
# to store arbitrary `key/value` pairs.
#
# This class provides an easy way to fetch the existing session secret, or
# generate and store one if it doesn't exist yet.
class SessionSecretManager
  class << self
    def fetch_or_create!
      ENV['SIMPLEE_FOOD_SESSION_SECRET'].tap { |env| return env if env }

      # If we are running a migration Rake task, the `configs` table might not
      # exist yet, which results in an error. In that case, just return `nil`
      # since the value we set for the session secret isn't important.
      return if running_migration_tasks?

      fetch_secret || create_secret!
    end

    private

    def create_secret!
      SecureRandom
        .hex(32)
        .tap { |sekrit| Config.create!(key: 'SESSION_SECRET', value: sekrit) }
    end

    def fetch_secret
      Config.lookup('SESSION_SECRET')
    end

    def running_migration_tasks?
      # When running a Rake task, the `Rake` constant will be defined. However,
      # during a normal app startup, `Rake` may not be defined.
      return false unless defined?(Rake)

      running_tasks = Rake.application.top_level_tasks
      (running_tasks & %w[db:create db:migrate db:migrate:status db:seed]).any?
    end
  end
end
