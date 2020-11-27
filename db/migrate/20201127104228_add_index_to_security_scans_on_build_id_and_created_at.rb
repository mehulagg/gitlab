# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexToSecurityScansOnBuildIdAndCreatedAt < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :security_scans, %i[build_id created_at]
  end

  def down
    remove_concurrent_index :security_scans, %i[build_id created_at], name: 'index_security_scans_on_build_id_and_created_at'
  end
end
