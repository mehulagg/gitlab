# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexOnWebHooksDisabledUntil < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  INDEX_NAME = 'index_web_hooks_on_disabled_until'

  disable_ddl_transaction!

  def up
    add_concurrent_index(:web_hooks, :disabled_until, name: INDEX_NAME)
  end

  def down
    remove_concurrent_index_by_name(:web_hooks, INDEX_NAME)
  end
end
