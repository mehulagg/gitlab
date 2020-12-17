# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class ChangePagesDeploymentSizeToBigint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    change_column_type_concurrently :pages_deployments, :size, :bigint
  end

  def down
    undo_change_column_type_concurrently :pages_deployments, :size
  end
end
