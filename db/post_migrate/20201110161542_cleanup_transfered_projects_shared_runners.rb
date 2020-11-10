# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CleanupTransferedProjectsSharedRunners < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute %(UPDATE projects SET shared_runners_enabled = false WHERE namespace_id IN (
      SELECT id FROM namespaces WHERE shared_runners_enabled = false AND allow_descendants_override_disabled_shared_runners = false
    ))
  end

  def down
  end
end
