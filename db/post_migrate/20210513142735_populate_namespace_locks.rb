# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class PopulateNamespaceLocks < ActiveRecord::Migration[6.0]
  def up
    execute 'INSERT INTO namespace_locks SELECT id FROM namespaces'
  end

  def down
    execute 'TRUNCATE namespace_locks'
  end
end
